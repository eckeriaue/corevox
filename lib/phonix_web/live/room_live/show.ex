defmodule PhonixWeb.RoomLive.Show do
  use PhonixWeb, :live_view
  # alias Phonix.Calls.Room
  alias Phonix.Calls

  @impl true
  def mount(_params, _session, %{assigns: %{current_scope: current_scope}} = socket)
      when is_nil(current_scope) do
    {:ok,
     socket
     |> put_flash(:info, "Чтобы войти в комнату вы должны быть авторизованы")
     |> redirect(to: PhonixWeb.UserAuth.signed_in_path(socket))}
  end

  def mount(params, _session, socket) do
    room_id = String.to_integer(params["id"])
    user = get_in(socket.assigns, [:current_scope, :user])

    if connected?(socket) do
      Phonix.PubSub |> Phoenix.PubSub.subscribe("call:#{Integer.to_string(room_id)}")
    end

    members =
      Calls.get_room_members(room_id)
      |> Enum.reject(fn member -> member.id == user.id end)

    case Calls.join_room(user, room_id) do
      {:error, _} ->
        {:ok,
         socket
         |> put_flash(:error, "При входе в комнату произошла ошибка")
         |> redirect(to: ~p"/rooms/#{room_id}/prepare")}

      {:ok, room_member} ->
        Phonix.PubSub |> Phoenix.PubSub.broadcast("call:#{room_id}", {:member_joined, room_id})

        {:ok,
         socket
         |> assign(:room_id, room_id)
         |> assign(:room_member, room_member)
         |> assign(:enable_micro, false)
         |> assign(:enable_camera, false)
         |> assign(:enable_audio, false)
         |> assign(:members, members)}
         # todo: use stream
         # |> stream(:members, members)}
    end
  end

  @impl true
  def terminate(_reason, %{assigns: %{current_scope: current_scope}} = socket) when not is_nil(current_scope) do
    current_scope.user |> Calls.leave_room(socket.assigns.room_id)
    :ok
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.call flash={@flash} current_scope={@current_scope}>
      <section class="grid grid-cols-5 h-full">
        <div class="bg-base-200 -mt-16" style="height: calc(100% + var(--spacing) * 16)">
          <div class="flex flex-col pt-16 h-full">
            <ul class="list grow text-sm text-base-content h-full overflow-y-scroll">
              <li id="me" class="list-row">
                {@current_scope.user.name}
              </li>

              <%!-- <ul id="members" phx-update="stream" class="list contents"> --%>
              <ul class="list contents">
                <%!-- <%= for {id, member} <- @streams.members do %> --%>
                <%= for member <- @members do %>
                  <li class="list-row items-center">
                    <span class="loading loading-ball loading-sm"></span>
                    <span class="text-xs truncate">{member.name}</span>
                    <.button class="btn btn-ghost btn-square">
                      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4">
                        <path stroke-linecap="round" stroke-linejoin="round" d="m11.25 11.25.041-.02a.75.75 0 0 1 1.063.852l-.708 2.836a.75.75 0 0 0 1.063.853l.041-.021M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9-3.75h.008v.008H12V8.25Z" />
                      </svg>
                    </.button>
                  </li>
                <% end %>
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
                class={[
                  "btn btn-circle ph ph-monitor",
                ]}
              ></.button>

            </div>
          </div>
        </div>

        <div class="col-span-4 grid grid-cols-3 p-4 gap-4 h-full bg-base-300">
          <.my_video enable_camera={@enable_camera} />
          <%= for member <- @members do %>
            <.remote_video whoami={member.name || member.email} id={member.id} />
          <% end %>
        </div>
      </section>
    </Layouts.call>
    """
  end

  @impl true
  def handle_event(toggle_state_media, unsigned_params, socket)
    when toggle_state_media == "toggle_micro" or
   toggle_state_media == "toggle_camera" or
   toggle_state_media == "toggle_audio" do
     case toggle_state_media do
       "toggle_micro" -> {:noreply, assign(socket, :enable_micro, !socket.assigns.enable_micro)}
       "toggle_camera" -> {:noreply, assign(socket, :enable_camera, !socket.assigns.enable_camera)}
       "toggle_audio" -> {:noreply, assign(socket, :enable_audio, !socket.assigns.enable_audio)}
     end
  end

  @impl true
  def handle_info({:member_joined, room_id}, socket) do
    user = get_in(socket.assigns, [:current_scope, :user])

    members =
      Calls.get_room_members(room_id)
      |> Enum.reject(fn member -> member.id == user.id end)

    {:noreply, assign(socket, :members, members)}
  end

  def my_video(assigns) do
    ~H"""
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
        hidden
        autoplay
        playsinline
        muted
        phx-hook="LocalVideo"
      />
      <% else %>
      <span class="ph ph-user text-4xl text-secondary" />
      <% end %>
    </div>
    """
  end

  def remote_video(assigns) do
    ~H"""
      <div style="width:300px;height:200px;" class="bg-base-200 relative rounded-2xl flex items-center justify-center overflow-hidden">
        <div class="absolute inset-0 size-full p-2">
          <span class="badge">{@whoami}</span>
        </div>
        <span class="loading loading-spinner loading-lg"></span>
        <video
          id={"remote_video-#{@id}"}
          hidden
          autoplay
          playsinline
          muted
        />
      </div>
    """
  end

end
