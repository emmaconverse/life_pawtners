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
    File.open(Rails.root.join("testcat.zip")) do |images_file|
      @cat_result = visual_recognition.classify(
        images_file: images_file,
        threshold: 0.1,
        classifier_ids: ["adult_animal_1921656686"]
      ).result
    end

      petfinder = Petfinder::Client.new(ENV["PETFINDER_API_KEY"], ENV["PETFINDER_SECRET_KEY"])

      @pets = petfinder.find_pets('cat', '29601')

  end

  def search
    # url = "http://api.petfinder.com/pet.find?key=b88545a30e0b53a33c5ab392ca03fd93&format=json&location=29609"
    # response = HTTParty.get(url)
    # puts response.body, response.code, response.message, response.headers.inspect

  end
end
