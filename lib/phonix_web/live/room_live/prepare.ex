defmodule PhonixWeb.RoomLive.Prepare do
  use PhonixWeb, :live_view

  @impl true
  def mount(params, _session, socket) do
    {:ok,
      socket
        |> assign(:room_id, params["id"])
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <%!-- <script src="//unpkg.com/alpinejs" defer></script> --%>
      <.header> Подготовьтесь к входу в комнату </.header>
      <section>
        <div id="video-container" class="bg-base-200 rounded-2xl overflow-hidden" style="width: 400px;height:300px">
          <video id="localVideo" autoplay muted playsinline style="width: 400px; height:300px"></video>
        </div>
        <.form id="controls" class="mt-4">
          <div class="tooltip" data-tip="Включить микрофон">
            <.button
              class="btn btn-ghost"
              id="micro"
              type="button"
            >
              🎤
            </.button>
          </div>

          <div class="tooltip" data-tip="Включить видео">
            <.button
              class="btn btn-ghost"
              id="camera"
              type="button"
            >
              📹
            </.button>
          </div>
          <.button href={~p"/rooms/#{@room_id}"}> Войти</.button>
        </.form>

        <script type="module">
          let microStream, cameraStream
          const cameraStatus = await navigator.permissions.query({ name: "camera" })
          const microStatus = await navigator.permissions.query({ name: "microphone" })

          if (microStatus.state === 'granted') micro.classList.remove('btn-ghost')
          if (cameraStatus.state === 'granted') camera.classList.remove('btn-ghost')

          micro.addEventListener('click', async event => {
            if (!microStream) {
              microStream = await navigator.mediaDevices.getUserMedia({ audio: true })
            } else {
              microStream = undefined
            }
            event.target.classList.toggle('btn-ghost')

          })
          camera.addEventListener('click', async event => {
            if (!cameraStream) {
              cameraStream = await navigator.mediaDevices.getUserMedia({ video: true })
              localVideo.srcObject = cameraStream
            } else {
              cameraStream.getTracks().forEach(track => track.stop())
              localVideo.srcObject = null
              cameraStream = undefined
            }
            event.target.classList.toggle('btn-ghost')
          })
        </script>

      </section>
    </Layouts.app>
    """
  end
end
