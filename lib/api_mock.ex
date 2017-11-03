defmodule ApiMock do
  use GenServer

  def start_link() do
    GenServer.start_link __MODULE__, :ok, [name: :mock_server]
  end

  # defp filter_header({"Location", _}), do: true
  # defp filter_header(_), do: false

  # defp get_random_page() do
  #   wiki = "https://en.wikipedia.org/wiki/Special:Random"

  #   HTTPoison.get(wiki)
  #   |> (fn {:ok, %{headers: headers}} -> headers end).()
  #   |> Enum.filter(&filter_header/1)
  #   |> (fn [{"Location", url} | _] -> url end).()
  # end

  # Fancy way
  # defp get_random_page() do
  #   wiki = "https://en.wikipedia.org/wiki/Special:Random"

  #   HTTPoison.get(wiki)
  #   |> (fn {:ok, %{headers: headers}} -> for {k,v} <- headers, k == "Location", do: v end).()
  # end

  # Very fancy way
  defp get_random_page() do
    wiki = "https://en.wikipedia.org/wiki/Special:Random"

    with {:ok, %{status_code: 302, headers: headers}} <- HTTPoison.get(wiki),
         {_, url} <- Enum.find(headers, fn {k, _} -> k == "Location" end) do
      {:ok, url}
    else
      _ -> {:error, :no_url_for_you}
    end
  end

  defp generate_endpoint(id) do
    with name <- ApiMock.Randomizer.randomizer(8, :alpha),
         {:ok, endpoint} <- get_random_page() do
      %{
        "name" => name,
        "id" => id,
        "endpoint" => endpoint
      }
    else
      e -> e
    end
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

  def reset_routes() do
    GenServer.cast :mock_server, :reset_routes
  end

  def get_endpoints() do
    GenServer.call :mock_server, :get_endpoints
  end

  # Calls
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:get_endpoints, _from, %{endpoints: endpoints}=state) do
    {:reply, endpoints, state}
  end

  # Casts
  def handle_cast(:reset_routes, _state) do
    endpoints = generate_endpoints()
    {:noreply, %{endpoints: endpoints}}
  end
end
