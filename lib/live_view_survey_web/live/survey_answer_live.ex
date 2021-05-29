defmodule LiveViewSurveyWeb.SurveyAnswerLive do
  @moduledoc false
  use LiveViewSurveyWeb, :live_view

  alias LiveViewSurvey.Surveys

  def mount(_params, session, socket) do
    {:ok, assign(socket, :voting_session_id, session["voting_session_id"])}
  end

  def handle_params(%{"id" => id}, _, socket) do
    survey = Surveys.get_survey!(id)

    {:noreply, assign(socket, :survey, survey)}
  end

  def render(assigns),
    do: ~L"""
    <p><%= @survey.title %> - <%= @voting_session_id %></p>
    """
end
