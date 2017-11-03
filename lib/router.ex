defmodule ApiMock.Router do
  use Plug.Router

  require Logger

  plug Plug.Parsers, parsers: [:urlencoded]
  plug Plug.Logger

  plug :match
  plug :dispatch

  get "/status" do
    conn |> send_resp(200, "ok")
  end

  get "/endpoints" do
    res = ApiMock.get_endpoints()

    conn |> send_resp(200, res |> Poison.encode!)
  end

  get "/*_rest" do
    conn |> send_resp(404, "Nope here zorry!")
  end

  patch "/reset_routes" do
    ApiMock.reset_routes

    conn |> send_resp(200, "Meh")
  end

  patch "/*_rest" do
    conn |> send_resp(404, "Nope here zorry!")
  end
end
