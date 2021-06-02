defmodule LiveViewSurvey.SurveysTest do
  use LiveViewSurvey.DataCase, async: true

  alias LiveViewSurvey.Surveys
  alias LiveViewSurvey.Surveys.{SessionSurvey, Survey}

  describe "surveys" do
    defp create_user_factory(attrs \\ []) do
      Factories.user(attrs)
      |> Repo.insert!()
    end

    test "list_surveys/1 returns all surveys from the specific user" do
      user_1 = create_user_factory()
      user_2 = create_user_factory(email: "user2@gmail.com")

      survey_1 = create_survey_factory(created_by: user_1.id)
      survey_2 = create_survey_factory(created_by: user_1.id)

      survey_3 = create_survey_factory(created_by: user_2.id)

      assert Surveys.list_surveys(user_1.id) == [survey_1, survey_2]
      assert Surveys.list_surveys(user_2.id) == [survey_3]
    end

    test "get_survey!/1 returns the survey with given id" do
      user = create_user_factory()
      survey = create_survey_factory(created_by: user.id)

      assert Surveys.get_survey!(survey.id) == survey
    end

    test "create_survey/1 with valid data creates a survey" do
      user = create_user_factory()

      option =
        option_factory(%{id: "80914d8e-74c8-4096-a7ed-3342d234361a", option: "some option"})

      valid_attrs = %{
        "title" => "some title",
        "options" => [option],
        "current_user" => user
      }

      assert {:ok, %Survey{} = survey} = Surveys.create_survey(valid_attrs)
      assert survey.title == "some title"
      assert survey.created_by == user.id
      assert length(survey.options) == 1

      survey_option = hd(survey.options)

      assert survey_option.id == "80914d8e-74c8-4096-a7ed-3342d234361a"
      assert survey_option.option == "some option"
      assert survey_option.votes == 0
    end

    test "create_survey/1 with nil title returns error changeset" do
      assert {:error, %Ecto.Changeset{} = changeset} = Surveys.create_survey(%{"title" => nil})
      assert %{title: ["can't be blank"]} = errors_on(changeset)
    end

    test "create_survey/1 with empty options returns error changeset" do
      assert {:error, %Ecto.Changeset{} = changeset} =
               Surveys.create_survey(%{"title" => "some title"})

      assert %{options: ["can't be blank"]} = errors_on(changeset)
    end

    test "create_survey/1 without a list of options returns error changeset" do
      option = option_factory()

      assert {:error, %Ecto.Changeset{} = changeset} =
               Surveys.create_survey(%{"title" => "some title", "options" => option})

      assert %{options: ["is invalid"]} = errors_on(changeset)
    end

    test "create_survey/1 with a invalid option returns error changeset" do
      option = %{}

      assert {:error, %Ecto.Changeset{} = changeset} =
               Surveys.create_survey(%{"title" => "some title", "options" => [option]})

      assert %{options: [%{id: ["can't be blank"], option: ["can't be blank"]}]} =
               errors_on(changeset)
    end

    test "create_survey/1 with invald user returns error changeset" do
      option = option_factory()

      assert {:error, %Ecto.Changeset{} = changeset} =
               Surveys.create_survey(%{
                 "title" => "some title",
                 "options" => [option],
                 "current_user" => ""
               })

      assert %{user: ["is invalid"]} = errors_on(changeset)
    end

    test "change_survey/1 returns a survey changeset" do
      user = create_user_factory()
      survey = create_survey_factory(created_by: user.id)

      assert %Ecto.Changeset{} = Surveys.change_survey(survey)
    end

    test "new_survey/0 returns a survey changeset with a default option" do
      assert %Ecto.Changeset{} = changeset = Surveys.new_survey()

      [option_changeset | _] = get_change(changeset, :options)
      assert get_change(option_changeset, :id) |> is_binary()
      assert get_change(option_changeset, :option) == "Option 01"
    end

    test "subscribe/1 returns ok" do
      assert :ok = Surveys.subscribe("topic:123")
    end
  end

  describe "voting" do
    setup :setup_create_user_factory

    test "vote/3 returns a ok tuple when the attrs are valid", %{user: user} do
      option = option_factory()
      survey = create_survey_factory(created_by: user.id, options: [option])
      session_id = Ecto.UUID.generate()

      assert {:ok, _survey} = Surveys.vote(survey.id, option.id, session_id)
    end

    test "vote/3 increments the vote of the option in the survey", %{user: user} do
      option = option_factory(%{votes: 5})
      survey = create_survey_factory(created_by: user.id, options: [option])
      session_id = Ecto.UUID.generate()

      {:ok, survey} = Surveys.vote(survey.id, option.id, session_id)

      voted_option = survey.options |> Enum.find(&(&1.id == option.id))

      assert voted_option.votes == 6
    end

    test "vote/3 should create a session_survey record", %{user: user} do
      option = option_factory()
      survey = create_survey_factory(created_by: user.id, options: [option])
      session_id = Ecto.UUID.generate()

      assert {:ok, survey} = Surveys.vote(survey.id, option.id, session_id)

      assert %SessionSurvey{} =
               Repo.get_by(SessionSurvey, session_id: session_id, survey_id: survey.id)
    end

    test "vote/3 returns NoResultsError when using an invalid survey_id" do
      invalid_survey_id = Ecto.UUID.generate()
      option = option_factory()
      session_id = Ecto.UUID.generate()

      assert_raise Ecto.NoResultsError, fn ->
        {:ok, _survey} = Surveys.vote(invalid_survey_id, option.id, session_id)
      end
    end

    test "session_already_voted?/2 returns true if the session are associated with the survey", %{
      user: user
    } do
      survey = create_survey_factory(created_by: user.id)
      session_id = Ecto.UUID.generate()

      # create association session_survey
      session_survey_factory(session_id: session_id, survey_id: survey.id)

      assert Surveys.session_already_voted?(survey.id, session_id)
    end

    test "session_already_voted?/2 returns false if the session and the survey doesn't exists" do
      survey_id = Ecto.UUID.generate()
      session_id = Ecto.UUID.generate()

      refute Surveys.session_already_voted?(survey_id, session_id)
    end

    test "session_already_voted?/2 returns false if the session aren't associated with the survey",
         %{user: user} do
      survey = create_survey_factory(created_by: user.id)
      session_id = Ecto.UUID.generate()

      refute Surveys.session_already_voted?(survey.id, session_id)
    end
  end

  defp setup_create_user_factory(_) do
    user =
      Factories.user()
      |> Repo.insert!()

    [user: user]
  end

  defp create_survey_factory(attrs) do
    Factories.survey(attrs)
    |> Repo.insert!()
  end

  defp option_factory(attrs \\ %{}) do
    Factories.option(attrs)
  end

  defp session_survey_factory(attrs) do
    Factories.session_survey(attrs)
    |> Repo.insert!()
  end
end
