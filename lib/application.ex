defmodule ApiMock.Application do
  use Application

  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    port = 8080

    children = [
      worker(ApiMock, []),
      Plug.Adapters.Cowboy.child_spec(:http, ApiMock.Router, [], port: port)
    ]

    opts = [strategy: :one_for_one, name: ApiMock.Supervisor]

    case Supervisor.start_link(children, opts) do
      {:ok, _} = ok ->
        Logger.info "Starting ApiMock"
        ok
      {:error, _} = error ->
        Logger.error "Error starting ApiMock"
        error
    end
  end
end
