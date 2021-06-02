defmodule LiveViewSurveyWeb.SurveyLiveTest do
  use LiveViewSurveyWeb.ConnCase

  import Phoenix.LiveViewTest

  alias LiveViewSurvey.Surveys

  defp setup_user(_context) do
    user =
      Factories.user()
      |> Repo.insert!()

    [user: user]
  end

  defp setup_user_login(context) do
    [conn: log_in_user(context.conn, context.user)]
  end

  defp setup_live_view(context) do
    {:ok, live_view, html} = live(context.conn, "/surveys")

    [lv: live_view, html: html]
  end

  defp create_survey(attrs) do
    {:ok, survey} =
      attrs
      |> Enum.into(%{"options" => [%{id: Ecto.UUID.generate(), option: "Option 01"}]})
      |> Surveys.create_survey()

    survey
  end

  test "redirects to login page if user is not logged in", %{conn: conn} do
    {:error, {:redirect, %{to: "/users/log_in"}}} = live(conn, "/surveys")
  end

  describe "Index" do
    setup [:setup_user, :setup_user_login, :setup_live_view]

    test "renders restricted page if user is logged in", %{lv: lv} do
      assert render(lv) =~ "Surveys"
    end

    test "lists all surveys and button create", %{lv: lv, html: html, user: user} do
      survey_1 = create_survey([{"title", "Test Survey 01"}, {"current_user", user}])
      survey_2 = create_survey([{"title", "Test Survey 02"}, {"current_user", user}])

      assert html =~ "Surveys"
      assert render(lv) =~ "Surveys"

      assert has_element?(lv, "#surveys a", "Create Survey")

      assert has_element?(lv, "#survey-#{survey_1.id} a", survey_1.title)
      assert has_element?(lv, "#survey-#{survey_1.id} a", "Voting URL")
      assert has_element?(lv, "#survey-#{survey_2.id}", survey_2.title)
      assert has_element?(lv, "#survey-#{survey_2.id} a", "Voting URL")
    end

    test "clicking create survey button patches new route", %{lv: lv} do
      lv
      |> element("#surveys a", "Create Survey")
      |> render_click()

      assert_patched(lv, "/surveys/new")
    end

    test "clicking survey title link redirects to show route", %{lv: lv, user: user} do
      survey = create_survey([{"title", "Test Survey 01"}, {"current_user", user}])

      lv
      |> element("#survey-#{survey.id} a", survey.title)
      |> render_click()

      assert_redirected(lv, "/surveys/#{survey.id}/show")
    end

    test "clicking survey votting url link redirects to votting route", %{lv: lv, user: user} do
      survey = create_survey([{"title", "Test Survey 01"}, {"current_user", user}])

      lv
      |> element("#survey-#{survey.id} a", "Voting URL")
      |> render_click()

      assert_redirected(lv, "/survey_answer/#{survey.id}/#{Slug.slugify(survey.title)}")
    end

    test "receives real-time updates", %{lv: lv, user: user} do
      survey = create_survey([{"title", "Test Survey 01"}, {"current_user", user}])

      assert has_element?(lv, "#survey-#{survey.id} a", survey.title)
    end
  end

  describe "Show" do
    setup [:setup_user, :setup_user_login]

    test "displays survey and the chart", %{conn: conn, user: user} do
      survey = create_survey([{"title", "Test Survey 01"}, {"current_user", user}])

      {:ok, lv, _html} = live(conn, Routes.survey_index_path(conn, :show, survey))

      assert has_element?(lv, "h1", "Survey results")
      assert has_element?(lv, "h2", survey.title)

      assert has_element?(lv, "#charting canvas[id=chart-canvas][phx-hook=BarChart]", "")
    end
  end

  describe "Form" do
    setup [:setup_user, :setup_user_login]

    test "displays the form to create a new survey", %{conn: conn} do
      {:ok, lv, _html} = live(conn, Routes.survey_index_path(conn, :new))

      assert has_element?(lv, "h2", "New Survey")
      assert has_element?(lv, "form", "")
      assert has_element?(lv, "#form-create label", "Title")
      assert has_element?(lv, "#form-create input[id=form-create_title]", "")
      assert has_element?(lv, "#form-create label", "Option")

      assert has_element?(
               lv,
               "#form-create input[id=form-create_options_0_option][value='Option 01']",
               ""
             )

      assert has_element?(lv, "#form-create span", "Add option")
      assert has_element?(lv, "#form-create button", "Save")
      assert has_element?(lv, "#form-create a", "Cancel")
    end

    test "saves new survey", %{conn: conn} do
      {:ok, lv, _html} = live(conn, Routes.survey_index_path(conn, :new))

      {:ok, _, html} =
        lv
        |> form("#form-create", %{survey: %{title: "New Survey 01"}})
        |> render_submit()
        |> follow_redirect(conn, Routes.survey_index_path(conn, :index))

      assert html =~ "Survey created successfully"
      assert html =~ "New Survey 01"
    end

    test "displays live validations", %{conn: conn} do
      {:ok, lv, _html} = live(conn, Routes.survey_index_path(conn, :new))

      lv
      |> form("#form-create", %{survey: %{title: ""}})
      |> render_change()

      assert has_element?(lv, "#form-create", "can't be blank")
    end

    test "clicking add option link add a new form input", %{conn: conn} do
      {:ok, lv, _html} = live(conn, Routes.survey_index_path(conn, :new))

      assert has_element?(lv, "#form-create label[for=form-create_options_0_option]", "Option")

      assert has_element?(
               lv,
               "#form-create input[id=form-create_options_0_option][value='Option 01']",
               ""
             )

      refute has_element?(lv, "#form-create label[for=form-create_options_1_option]", "Option")

      refute has_element?(
               lv,
               "#form-create input[id=form-create_options_0_option][value='New option']",
               ""
             )

      lv
      |> element("#form-create span", "Add option")
      |> render_click()

      assert has_element?(lv, "#form-create label[for=form-create_options_1_option]", "Option")

      assert has_element?(
               lv,
               "#form-create input[id=form-create_options_1_option][value='Option 01']",
               ""
             )

      assert has_element?(lv, "#form-create label[for=form-create_options_0_option]", "Option")

      assert has_element?(
               lv,
               "#form-create input[id=form-create_options_0_option][value='New option']",
               ""
             )
    end

    test "clicking cancel button patches back to index", %{conn: conn} do
      {:ok, lv, _html} = live(conn, Routes.survey_index_path(conn, :new))

      lv
      |> element("#form-create a", "Cancel")
      |> render_click()

      assert_patched(lv, "/surveys")
    end
  end
end
