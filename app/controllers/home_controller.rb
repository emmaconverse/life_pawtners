require("ibm_watson/visual_recognition_v3")

class HomeController < ApplicationController

  def index
  end

# wherever you need the watson one
  def new
    # using IAM
    visual_recognition = IBMWatson::VisualRecognitionV3.new(
      version: "2018-03-19",
      iam_apikey: ENV["WATSON_API_KEY"]
    )

# maybe put in a job?
    File.open(Rails.root.join("testcat.zip")) do |images_file|
      cat_result = visual_recognition.classify(
        images_file: images_file,
        threshold: 0.1,
        classifier_ids: ["adult_animal_1921656686"]
      ).result
      render json: cat_result
    end

    end




end
