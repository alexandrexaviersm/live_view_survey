defmodule LiveViewSurveyWeb.SurveyLive.Index do
  use LiveViewSurveyWeb, :live_view

  alias LiveViewSurvey.Surveys
  alias LiveViewSurvey.Surveys.Survey

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :surveys, list_surveys())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Survey")
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

    {:noreply, assign(socket, :surveys, list_surveys())}
  end

  defp list_surveys do
    Surveys.list_surveys()
  end
end
