defmodule orvoxWeb.RoomLive.Prepare do
  use orvoxWeb, :live_view

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:room_id, params["id"])}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.button type="button" href={~p"/"} class="btn btn-ghost">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="size-6"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M6.75 15.75 3 12m0 0 3.75-3.75M3 12h18"
          />
        </svg>
        <span>Обратно</span>
      </.button>
      <.header>Подготовьтесь к входу в комнату</.header>
      <section>
        <div
          id="video-container"
          class="bg-base-200 rounded-2xl overflow-hidden"
          style="width: 400px;height:300px"
        >
          <video id="localVideo" autoplay muted playsinline style="width: 400px; height:300px">
          </video>
        </div>
        <form id="controls" class="mt-4">
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
        </form>

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
