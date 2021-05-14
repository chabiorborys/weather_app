defmodule Weather.Worker do

  def loop do
    receive do
      {sender_pid, location} ->
        send(sender_pid, {:ok, temperature_of(location)})
       _ ->
        IO.puts "Don't know how to process this message"
    end
    loop()
  end
  def temperature_of(location) do
    #Data transformation: from URL to HTTP response to parsing that response
    result = url_for(location) |> HTTPoison.get |> parse_response
    case result do
      #A successfuly parsed response returns the temperature and location.
      {:ok, temp} ->
        "#{location}: #{temp}°C"
      #If not successfull, an error message is returned
      :error ->
        "#{location} not found"
    end
  end

  defp url_for(location) do
    location = URI.encode(location)
    "http://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{apikey}"
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body |> JSON.decode! |> compute_temperature
  end

  defp parse_response(_) do
    :error
  end

  defp compute_temperature(json) do
    try do
      temp = (json["main"]["temp"] - 273.15) |> Float.round(1)
      {:ok, temp}
    rescue
      _ -> :error
    end
  end

  defp apikey do
    "a710e01ed4ba1db0e61ba8bd43f077a9"
  end
end
