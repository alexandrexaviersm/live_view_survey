defmodule LiveViewSurveyWeb.SurveyLive.FormComponent do
  @moduledoc """
  LiveComponent that renders :new action
  """
  use LiveViewSurveyWeb, :live_component

  alias LiveViewSurvey.Surveys

  def update(assigns, socket) do
    changeset = Surveys.new_survey()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  def handle_event("validate", %{"survey" => survey_params}, socket) do
    changeset =
      socket.assigns.survey
      |> Surveys.change_survey(survey_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("add-option", _, socket) do
    new_option = %{id: Ecto.UUID.generate(), option: "New option"}

    options = [new_option | socket.assigns.changeset.changes.options]

    socket = update_socket_changeset(socket, options)

    {:noreply, socket}
  end

  def handle_event("remove-option", %{"id" => option_id}, socket) do
    options =
      Enum.reject(socket.assigns.changeset.changes.options, fn option ->
        option.changes.id == option_id
      end)

    socket = update_socket_changeset(socket, options)

    {:noreply, socket}
  end

  def handle_event("save", %{"survey" => survey_params}, socket) do
    survey_params
    |> Map.put("current_user", socket.assigns.current_user)
    |> Surveys.create_survey()
    |> case do
      {:ok, _survey} ->
        {:noreply,
         socket
         |> put_flash(:info, "Survey created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp update_socket_changeset(socket, options) do
    assign(
      socket,
      :changeset,
      Ecto.Changeset.put_embed(socket.assigns.changeset, :options, options)
    )
  end
end
