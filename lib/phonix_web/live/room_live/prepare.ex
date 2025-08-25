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
      <script src="//unpkg.com/alpinejs" defer></script>
      <.header> Подготовьтесь к входу в комнату </.header>
      <div
        x-data="{
          enableMicro: false,
          enableVideo: false,
          mediaMicro: null,
          mediaVideo: null,
        }"
      >
        <div id="video-container" class="bg-base-200 rounded-2xl overflow-hidden" style="width: 400px;">
          <video id="localVideo" autoplay muted playsinline style="width: 400px;"></video>
        </div>
        <div id="controls" class="mt-4">
        <div class="tooltip" data-tip="Включить микрофон">
          <.button
            class="btn btn-ghost"
            x-bind:class="enableMicro ? 'btn-active' : 'btn-ghost'"
            x-on:click="enableMicro = !enableMicro"
          >
            🎤
          </.button>
        </div>

        <div class="tooltip" data-tip="Включить видео">
          <.button
            class="btn btn-ghost"
            x-bind:class="enableVideo ? 'btn-active' : 'btn-ghost'"
            x-on:click="enableVideo = !enableVideo"
          >
            📹
          </.button>
        </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
