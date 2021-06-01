defmodule LiveViewSurveyWeb.SurveyLive.Index do
  @moduledoc """
  LiveView that renders the Survey screens - actions :index, :new and :show
  """
  use LiveViewSurveyWeb, :live_view

  alias LiveViewSurvey.Surveys
  alias LiveViewSurvey.Surveys.Survey

  @impl true
  def mount(_params, session, socket) do
    socket = assign_current_user(socket, session)

    if connected?(socket), do: Surveys.subscribe("user:#{socket.assigns.current_user.id}")

    {:ok, assign(socket, :surveys, list_surveys(socket.assigns.current_user.id))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_info(:survey_created, socket) do
    {:noreply, assign(socket, :surveys, list_surveys(socket.assigns.current_user.id))}
  end

  @impl true
  def handle_info({:survey_updated, survey}, socket) do
    chart_data = %{
      labels: Enum.map(survey.options, & &1.option),
      values: Enum.map(survey.options, & &1.votes)
    }

    socket = push_event(socket, "update-votes", chart_data)

    {:noreply, socket}
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    socket
    |> assign(:page_title, "Show Survey")
    |> assign(:survey, Surveys.get_survey!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Survey")
    |> assign(:survey, %Survey{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Surveys")
    |> assign(:survey, nil)
  end

  defp list_surveys(user_id) do
    Surveys.list_surveys(user_id)
  end
end
