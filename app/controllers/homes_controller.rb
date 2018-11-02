require "ibm_watson/visual_recognition_v3"
require "httparty"
require "petfinder"

class HomesController < ApplicationController

  def new
    @visual_recognition = IBMWatson::VisualRecognitionV3.new
  end

  def create
    @visual_recognition = IBMWatson::VisualRecognitionV3.new(
      version: "2018-03-19",
      iam_apikey: ENV["WATSON_API_KEY"]
    )
    # maybe put in a job?
    File.open(params[:file_upload][:uploaded_file].tempfile) do |image|
      result = @visual_recognition.classify(
        images_file: image,
        threshold: 0,
        classifier_ids: ["default"]
      ).result["images"][0]["classifiers"][0]["classes"]

      breeds_sorted = remove_banned_class_names(result)
        .sort_by { |hash| hash["score"] }
        .reject { |result| result["class"].include? "color" }
        .max_by(2) { |result| result["score"] }
      @breed = breeds_sorted.map { |breed| breed["class"].remove(" dog") }.first.try :titleize

      age_result = visual_recognition.classify(
        images_file: image,
        threshold: 0.6,
        owners: ["me"]
      ).result["images"][0]["classifiers"][0]["classes"]
    end

    redirect_to homes_path(breed: @breed)
  end


  def index
    @breed = params[:breed]

    petfinder = Petfinder::Client.new(ENV["PETFINDER_API_KEY"], ENV["PETFINDER_SECRET_KEY"])
    @pets = petfinder.find_pets('dog', 29601, breed: "#{@breed}", age: "Adult", count: 25)
    # paged results?
  end

  def show
  end

private

  def remove_banned_class_names(classes)
    classes.reject do |class_data|
      banned_class_names.include?(class_data["class"])
    end
  end

  def banned_class_names
    ["cat", "dog", "carnivore", "mammal", "animal", "domestic animal"]
  end

end
