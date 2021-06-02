defmodule LiveViewSurveyWeb.SurveyAnswerLiveTest do
  use LiveViewSurveyWeb.ConnCase

  import Phoenix.LiveViewTest

  alias LiveViewSurvey.Surveys

  defp setup_user(_context) do
    user =
      Factories.user()
      |> Repo.insert!()

    [user: user]
  end

  defp create_survey(context) do
    option_id_1 = Ecto.UUID.generate()
    option_id_2 = Ecto.UUID.generate()

    options = [
      %{id: option_id_1, option: "Option 01"},
      %{id: option_id_2, option: "Option 02"}
    ]

    {:ok, survey} =
      [{"title", "Test Survey 01"}, {"current_user", context.user}, {"options", options}]
      |> Enum.into(%{})
      |> Surveys.create_survey()

    [survey: survey, option: option_id_2]
  end

  describe "Take survey" do
    setup [:setup_user, :create_survey]

    test "renders the survey options", %{conn: conn, survey: survey} do
      {:ok, lv, _html} = live(conn, "/survey_answer/#{survey.id}/#{Slug.slugify(survey.title)}")

      assert has_element?(lv, "h1", "Take the survey")
      assert has_element?(lv, "h2", survey.title)

      assert has_element?(lv, "label", "Option 01")
      assert has_element?(lv, "label", "Option 02")

      assert has_element?(lv, "button", "Save")
    end

    test "should submit a vote and show the chart", %{conn: conn, survey: survey, option: option} do
      {:ok, lv, _html} = live(conn, "/survey_answer/#{survey.id}/#{Slug.slugify(survey.title)}")

      lv
      |> form("#vote", %{option: option})
      |> render_submit()

      assert has_element?(lv, "p", "The vote was registered")
      assert has_element?(lv, "#charting canvas[id=chart-canvas][phx-hook=BarChart]", "")
    end
  end
end
