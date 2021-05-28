defmodule LiveViewSurvey.SurveysTest do
  use LiveViewSurvey.DataCase, async: true

  alias LiveViewSurvey.Surveys

  describe "surveys" do
    alias LiveViewSurvey.Surveys.Survey

    @update_attrs %{"title" => "some updated title"}
    @invalid_attrs %{"title" => nil}

    def user_factory(attrs \\ []) do
      Factories.user(attrs)
      |> Repo.insert!()
    end

    def survey_factory(attrs \\ []) do
      Factories.survey(attrs)
      |> Repo.insert!()
    end

    test "list_surveys/1 returns all surveys from the specific user" do
      user_1 = user_factory()
      user_2 = user_factory(email: "user2@gmail.com")

      survey_1 = survey_factory(created_by: user_1.id)
      survey_2 = survey_factory(created_by: user_1.id)

      survey_3 = survey_factory(created_by: user_2.id)

      assert Surveys.list_surveys(user_1.id) == [survey_1, survey_2]
      assert Surveys.list_surveys(user_2.id) == [survey_3]
    end

    test "get_survey!/1 returns the survey with given id" do
      user = user_factory()
      survey = survey_factory(created_by: user.id)

      assert Surveys.get_survey!(survey.id) == survey
    end

    test "create_survey/1 with valid data creates a survey" do
      user = user_factory()
      valid_attrs = %{"title" => "some title", "current_user" => user}

      assert {:ok, %Survey{} = survey} = Surveys.create_survey(valid_attrs)
      assert survey.title == "some title"
    end

    test "create_survey/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Surveys.create_survey(@invalid_attrs)
    end

    test "update_survey/2 with valid data updates the survey" do
      user = user_factory()
      survey = survey_factory(created_by: user.id)

      assert {:ok, %Survey{} = survey} = Surveys.update_survey(survey, @update_attrs)
      assert survey.title == "some updated title"
    end

    test "update_survey/2 with invalid data returns error changeset" do
      user = user_factory()
      survey = survey_factory(created_by: user.id)

      assert {:error, %Ecto.Changeset{}} = Surveys.update_survey(survey, @invalid_attrs)
      assert survey == Surveys.get_survey!(survey.id)
    end

    test "delete_survey/1 deletes the survey" do
      user = user_factory()
      survey = survey_factory(created_by: user.id)

      assert {:ok, %Survey{}} = Surveys.delete_survey(survey)
      assert_raise Ecto.NoResultsError, fn -> Surveys.get_survey!(survey.id) end
    end

    test "change_survey/1 returns a survey changeset" do
      user = user_factory()
      survey = survey_factory(created_by: user.id)

      assert %Ecto.Changeset{} = Surveys.change_survey(survey)
    end
  end
end
