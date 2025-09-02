defmodule orvoxWeb.RoomLive.Show do
  use orvoxWeb, :live_view

  @impl true
  def mount(_params, _session, %{assigns: %{current_scope: current_scope}} = socket)
      when is_nil(current_scope) do
    {:ok,
     socket
     |> put_flash(:info, "Чтобы войти в комнату вы должны быть авторизованы")
     |> redirect(to: orvoxWeb.UserAuth.signed_in_path(socket))}
  end

  def mount(%{"id" => room_id}, _session, socket) do

    if connected?(socket) do
      user = socket.assigns.current_scope.user
      topic = "room:#{room_id}"
      orvoxWeb.Endpoint.subscribe(topic)
      Phoenix.PubSub.subscribe(orvox.PubSub, "room-call:#{room_id}")

      {:ok, _} = orvoxWeb.Presence.track(
        self(),
        topic,
        user.id,
        %{
          name: user.name,
          id: user.id,
          email: user.email,
          joined_at: System.system_time(:second),
        }
      )
    end

    {:ok, socket
      |> assign(:room_id, room_id)
      |> assign(:enable_micro, false)
      |> assign(:enable_camera, false)
      |> assign(:enable_audio, false)
      |> assign(:members, presence_members(room_id))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.call flash={@flash} current_scope={@current_scope}>
      <script
        :type={Phoenix.LiveView.ColocatedHook}
        name=".Join"
      >
        export default {
          async mounted() {
            const config = {
              iceServers: [
                { urls: "stun:192.168.0.21:3478" },
                {
                  urls: "turn:192.168.0.21:3478",
                  username: 'webrtcuser',
                  credential: 'webrtccred'
                }
              ]
            }
            let members = JSON.parse(this.el.dataset.members)
            const fromUserId = parseInt(this.el.dataset.fromUserId)
            const pcsMembers = members.map((member) => {
              const pc = new RTCPeerConnection(config)
              pc.addEventListener('icecandidate', event => {
                if (event.candidate) {
                  this.pushEvent('icecandidate', { candidate: event.candidate, toUserId: member.id, fromUserId })
                }
              })
              pc.addEventListener('track', event => {
                document.dispatchEvent(new CustomEvent('remote-video:track', {
                  detail: { toUserId: event.fromUserId, track: event.track, streams: event.streams }
                }))
              })
              return {
                pc,
                member
              }
            })


            document.addEventListener('local-video:enable', event => {
              const stream = event.detail.stream
              pcsMembers.forEach(pcm => {
                stream.getTracks().forEach(async track => {
                  await pcm.pc.addTrack(track, stream)
                  const offer = await pcm.pc.createOffer()
                  await pcm.pc.setLocalDescription(offer)
                  this.pushEvent('offer', { fromUserId, toUserId: pcm.member.id, offer })
                })
              })
            })

            await Promise.all(
              pcsMembers.map(async ({ member, pc }) => {
                const offer = await pc.createOffer()
                await pc.setLocalDescription(offer)
                this.pushEvent('offer', { fromUserId, toUserId: member.id, offer })
                return Promise.resolve()
              })
            )

            this.handleEvent('icecandidate_delivery', event => {
              console.info('icecandidate_delivery', event)
            })

            this.handleEvent('answer_delivery', event => {
              console.info('answer_delivery', event)
              if (event.toUserId === fromUserId) {
                const pcm = pcsMembers.find(pcsm => pcsm.member.id === event.fromUserId)
                if (pcm.pc.signalingState === 'have-local-offer') {
                  pcm.pc.setRemoteDescription(new RTCSessionDescription(event.answer))
                }
              }
            })

            this.handleEvent('offer_delivery', async event => {
              if (event.toUserId === fromUserId) {
                members = JSON.parse(this.el.dataset.members)
                if (members.length > pcsMembers.length) {
                  members.filter(member => pcsMembers.findIndex(pcsm => pcsm.id === member.id) === -1)
                    .forEach(async member => {
                      const pc = new RTCPeerConnection(config)
                      pc.addEventListener('icecandidate', event => {
                        if (event.candidate) {
                          this.pushEvent('icecandidate', { candidate: event.candidate, toUserId: member.id, fromUserId })
                        }
                      })
                      pc.addEventListener('track', event => {
                        console.info('track event', event)
                        document.dispatchEvent(new CustomEvent('remote-video:track', {
                          detail: { toUserId: event.fromUserId, track: event.track, streams: event.streams }
                        }))
                      })
                      await pc.setRemoteDescription(event.offer)
                      const answer = await pc.createAnswer()
                      await pc.setLocalDescription(new RTCSessionDescription(answer))
                      pcsMembers.push({ member, pc })
                      this.pushEvent('answer', { fromUserId: event.toUserId, answer, toUserId: event.fromUserId })
                    })
                } else {
                  const pcm = pcsMembers.find(pcm => pcm.member.id === event.fromUserId)
                  console.info(pcm)
                  await pcm.pc.setRemoteDescription(new RTCSessionDescription(event.offer))
                  const answer = await pcm.pc.createAnswer()
                  await pcm.pc.setLocalDescription(new RTCSessionDescription(answer))
                  this.pushEvent('answer', { fromUserId: event.toUserId, answer, toUserId: event.fromUserId })
                }
              }
            })

          }
        }
      </script>
      <section
        class="grid grid-cols-5 h-full"
        id="room-container"
        phx-hook=".Join"
        data-members={Jason.encode!(@members |> Enum.filter(fn member -> member.id !== @current_scope.user.id end))}
        data-from-user-id={@current_scope.user.id}
      >
        <div class="bg-base-200 -mt-16" style="height: calc(100% + var(--spacing) * 16)">
          <div class="flex flex-col pt-16 h-full">
            <ul class="list grow text-sm text-base-content h-full overflow-y-scroll">

              <li id="me" class="list-row">
                {@current_scope.user.name}
              </li>

              <ul class="list contents">
                  <li
                    :for={member <- @members}
                    :if={member.id != @current_scope.user.id}
                    id={"info-list-members-#{member.id}"}
                    class="list-row items-center"
                  >
                    <span class="loading loading-ball loading-sm"></span>
                    <span class="text-xs truncate">{member.name}</span>
                    <.button class="btn btn-ghost btn-square">
                      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4">
                        <path stroke-linecap="round" stroke-linejoin="round" d="m11.25 11.25.041-.02a.75.75 0 0 1 1.063.852l-.708 2.836a.75.75 0 0 0 1.063.853l.041-.021M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9-3.75h.008v.008H12V8.25Z" />
                      </svg>
                    </.button>
                  </li>
              </ul>
            </ul>

            <div class="mx-2 border-t-2 p-4 border-base-100">

              <.button
                phx-click="toggle_micro"
                class={[
                  "btn btn-circle ph",
                  if(@enable_micro, do: "ph-microphone", else: "ph-microphone-slash")
                ]}
                ></.button>
              <.button
                phx-click="toggle_camera"
                class={[
                  "btn btn-circle ph",
                  if(@enable_camera, do: "ph-camera", else: "ph-camera-slash")
                ]}
                ></.button>
              <.button
                phx-click="toggle_audio"
                class={[
                  "btn btn-circle ph",
                  if(@enable_audio, do: "ph-ear", else: "ph-ear-slash")
                ]}
                ></.button>
              <.button
                class="btn btn-circle ph ph-monitor"
              ></.button>

            </div>
          </div>
        </div>

        <div class="col-span-4 grid grid-cols-3 p-4 gap-4 h-full bg-base-300">
          <.my_video enable_camera={@enable_camera} />
            <div
              :for={member <- @members}
              :if={member.id != @current_scope.user.id}
              id={"remote-video-members-#{member.id}"}
              class="contents"
            >
            <.remote_video
              whoami={member.name || member.email}
              video_id={member.id}
            />
            </div>
        </div>
      </section>
    </Layouts.call>
    """
  end

  @impl true
  def handle_event(toggle_state_media, _unsigned_params, socket)
    when toggle_state_media == "toggle_micro" or
   toggle_state_media == "toggle_camera" or
   toggle_state_media == "toggle_audio" do
     case toggle_state_media do
       "toggle_micro" -> {:noreply, assign(socket, :enable_micro, !socket.assigns.enable_micro)}
       "toggle_camera" -> {:noreply, assign(socket, :enable_camera, !socket.assigns.enable_camera)}
       "toggle_audio" -> {:noreply, assign(socket, :enable_audio, !socket.assigns.enable_audio)}
     end
  end

  def handle_event("leave_room", _params, socket) do
    topic = "room:" <> socket.assigns.room_id
    orvoxWeb.Presence.untrack(self(), topic, socket.assigns.current_scope.user.id)
    {:noreply, socket}
  end


  def handle_event("offer", %{"offer" => offer, "fromUserId" => fromUserId, "toUserId" => toUserId} = payload, socket) do
    orvox.PubSub |> Phoenix.PubSub.broadcast("room-call:#{socket.assigns.room_id}", {:offer_delivery, payload})
    {:noreply, socket}
  end

  def handle_info({:offer_delivery, payload}, socket) do
    {:noreply, push_event(socket, "offer_delivery", payload)}
  end

  def handle_event("icecandidate", payload, socket) do
    orvox.PubSub |> Phoenix.PubSub.broadcast("room-call:#{socket.assigns.room_id}", {:icecandidate_delivery, payload})
    {:noreply, socket}
  end

  def handle_info({:icecandidate_delivery, payload}, socket) do
    {:noreply, push_event(socket, "icecandidate_delivery", payload)}
  end

  def handle_event("answer", %{"answer" => answer, "fromUserId" => fromUserId, "toUserId" => toUserId} = payload, socket) do
    orvox.PubSub |> Phoenix.PubSub.broadcast("room-call:#{socket.assigns.room_id}", {:answer_delivery, payload})
    {:noreply, socket}
  end

  def handle_info({:answer_delivery, payload}, socket) do
    {:noreply, push_event(socket, "answer_delivery", payload)}
  end


  defp presence_members(room_id) do
    orvoxWeb.Presence.list("room:" <> room_id)
    |> Enum.map(fn {_key, %{metas: metas}} ->
      List.first(metas)
    end)
  end


  @impl true
  def handle_info(%{event: "presence_diff", payload: _diff}, socket) do
    {:noreply, socket
    |> assign(:members, presence_members(socket.assigns.room_id))}
  end


  def my_video(assigns) do
    ~H"""
    <script :type={Phoenix.LiveView.ColocatedHook} name=".MyVideo">
      export default {
        async mounted() {
          const stream = await navigator.mediaDevices.getUserMedia({ video: true })
          this.el.srcObject = stream
          this.el.addEventListener('loadedmetadata', (event) => {
            const loadingIndicator = document.querySelector(event.target.dataset.loadingIndicator)
            if (loadingIndicator) {
              loadingIndicator.hidden = true
            }
            this.el.hidden = false
            document.dispatchEvent(new CustomEvent('local-video:enable', { detail: { stream } }))
          }, { once: true })
        }
      }
    </script>
    <div
      style="width:300px;height:200px;"
      class="ring ring-base-100 bg-base-200 relative rounded-2xl flex items-center justify-center overflow-hidden"
    >
      <div class="absolute inset-0 size-full p-2">
        <span class="badge">Вы</span>
      </div>
      <%= if @enable_camera do %>
      <span id="my_video_spinner" class="loading loading-spinner loading-lg"></span>
      <video
        id="my_video"
        data-loading-indicator="#my_video_spinner"
        phx-hook=".MyVideo"
        hidden
        autoplay
        playsinline
        muted
      />
      <% else %>
      <span class="ph ph-user text-4xl text-secondary" />
      <% end %>
    </div>
    """
  end

  def remote_video(assigns) do
    ~H"""
      <script :type={Phoenix.LiveView.ColocatedHook} name=".RemoteVideo">
        export default {
          mounted() {
            document.addEventListener('remote-video:track', event => {
              this.el.srcObject = event.detail.streams.at(0)
            })
          }
        }
      </script>
      <div style="width:300px;height:200px;" class="ring ring-base-100 bg-base-200 relative rounded-2xl flex items-center justify-center overflow-hidden">
        <div class="absolute inset-0 size-full p-2">
          <span class="badge">{@whoami}</span>
        </div>
        <video
          id={"remote-video-id-#{@whoami}"}
          autoplay
          playsinline
          muted
          phx-hook=".RemoteVideo"
        />
      </div>
    """
  end

end
