defmodule ApiMock do
  use GenServer

  def start_link() do
    GenServer.start_link __MODULE__, :ok, [name: :mock_server]
  end

  defp filter_header({"Location", _}), do: true
  defp filter_header(_), do: false

  defp get_random_page() do
    wiki = "https://en.wikipedia.org/wiki/Special:Random"

    HTTPoison.get(wiki)
    |> (fn {:ok, %{headers: headers}} -> headers end).()
    |> Enum.filter(&filter_header/1)
    |> (fn [{"Location", url} | _] -> url end).()
  end

  defp generate_endpoint(id) do
    %{
      "name" => ApiMock.Randomizer.randomizer(8, :alpha),
      "id" => id,
      "endpoint" => get_random_page()
    }
  end

  defp generate_endpoints() do
    Enum.random(3..10)
    |> (fn x -> 1..x end).()
    |> Enum.map(&generate_endpoint/1)
  end

  def init(:ok) do
    endpoints = generate_endpoints()
    {:ok, %{endpoints: endpoints}}
  end

  def get_state() do
    GenServer.call :mock_server, :get_state
  end

  def get_endpoints() do
    GenServer.call :mock_server, :get_endpoints
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:get_endpoints, _from, %{endpoints: endpoints}=state) do
    {:reply, endpoints, state}
  end
end
