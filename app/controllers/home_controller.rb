require "ibm_watson/visual_recognition_v3"
require "httparty"
require "petfinder"

class HomeController < ApplicationController
  def index
  end

  def new


    # using IAM
    visual_recognition = IBMWatson::VisualRecognitionV3.new(
      version: "2018-03-19",
      iam_apikey: ENV["WATSON_API_KEY"]
    )
    # maybe put in a job?
    File.open(Rails.root.join("pup-on-bed.jpg.zip")) do |images_file|
      result = visual_recognition.classify(
        images_file: images_file,
        threshold: 0,
        # owners: ["IBM"]
        # classifier_ids: ["default", "adult_animal_1921656686"]
        classifier_ids: ["default"]
      ).result

      all_classes = result["images"][0]["classifiers"][0]["classes"]
      allowed_classes_sorted = remove_banned_class_names(all_classes).sort_by { |hash| hash["score"] }
      @display = allowed_classes_sorted.find_all { |result| result["class"].include? "dog" }.max_by(2) { |result| result["score"] }


      # @custom = visual_recognition.classify(
      #   images_file: images_file,
      #   threshold: 0.0,
      #   owners: ["me"]
      # ).result

    end

    petfinder = Petfinder::Client.new(ENV["PETFINDER_API_KEY"], ENV["PETFINDER_SECRET_KEY"])
    puts petfinder
    @pets = petfinder.find_pets('dog', 29601, breed: 'Newfoundland Dog', count: 5)
    # paged results?
  end

  def search
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
