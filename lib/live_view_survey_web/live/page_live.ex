defmodule LiveViewSurveyWeb.PageLive do
  @moduledoc false
  use LiveViewSurveyWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, push_redirect(socket, to: "/surveys")}
  end
end
