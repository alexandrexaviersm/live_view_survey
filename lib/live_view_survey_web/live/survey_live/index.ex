defmodule LiveViewSurveyWeb.SurveyLive.Index do
  use LiveViewSurveyWeb, :live_view

  alias LiveViewSurvey.Surveys
  alias LiveViewSurvey.Surveys.Survey

  @impl true
  def mount(_params, session, socket) do
    socket = assign_current_user(socket, session)

    {:ok, assign(socket, :surveys, list_surveys(socket.assigns.current_user.id))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
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

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    survey = Surveys.get_survey!(id)
    {:ok, _} = Surveys.delete_survey(survey)

    {:noreply, assign(socket, :surveys, list_surveys(socket.assigns.current_user.id))}
  end

  defp list_surveys(user_id) do
    Surveys.list_surveys(user_id)
  end
end
