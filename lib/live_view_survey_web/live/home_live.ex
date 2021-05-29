defmodule LiveViewSurveyWeb.HomeLive do
  @moduledoc false
  use LiveViewSurveyWeb, :live_view

  def mount(_params, session, socket) do
    socket = assign_current_user(socket, session)

    case socket.assigns.current_user do
      nil ->
        {:ok, push_redirect(socket, to: "/users/log_in")}

      _ ->
        {:ok, push_redirect(socket, to: "/surveys")}
    end
  end

  def render(assigns),
    do: ~L"""

    """
end
