defmodule LiveViewSurveyWeb.SurveyLive.FormComponent do
  use LiveViewSurveyWeb, :live_component

  alias LiveViewSurvey.Surveys

  @impl true
  def update(%{survey: survey} = assigns, socket) do
    changeset = Surveys.change_survey(survey)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"survey" => survey_params}, socket) do
    changeset =
      socket.assigns.survey
      |> Surveys.change_survey(survey_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"survey" => survey_params}, socket) do
    save_survey(socket, socket.assigns.action, survey_params)
  end

  defp save_survey(socket, :edit, survey_params) do
    case Surveys.update_survey(socket.assigns.survey, survey_params) do
      {:ok, _survey} ->
        {:noreply,
         socket
         |> put_flash(:info, "Survey updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_survey(socket, :new, survey_params) do
    case Surveys.create_survey(survey_params) do
      {:ok, _survey} ->
        {:noreply,
         socket
         |> put_flash(:info, "Survey created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
