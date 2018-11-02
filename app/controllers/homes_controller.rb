require "ibm_watson/visual_recognition_v3"
require "httparty"
require "petfinder"

class HomesController < ApplicationController

  def new
    @visual_recognition = IBMWatson::VisualRecognitionV3.new
  end

  def create
    visual_recognition = IBMWatson::VisualRecognitionV3.new(
      version: "2018-03-19",
      iam_apikey: ENV["WATSON_API_KEY"]
    )
    # maybe put in a job?
    File.open(params[:file_upload][:uploaded_file].tempfile) do |image|
      result = visual_recognition.classify(
        images_file: image,
        threshold: 0,
        classifier_ids: ["default"]
      ).result["images"][0]["classifiers"][0]["classes"]

      breeds_sorted = remove_banned_class_names(result)
        .sort_by { |hash| hash["score"] }
        .reject { |result| result["class"].include? "color" }
        .max_by(2) { |result| result["score"] }
      @breed = breeds_sorted.map { |breed| breed["class"].remove(" dog") }.first.try :titleize

      # age_result = visual_recognition.classify(
      #   images_file: image,
      #   threshold: 0.6,
      #   owners: ["me"]
      # ).result["images"][0]["classifiers"][0]["classes"]
    end

    redirect_to homes_path(breed: @breed)
  end


  def index
    @breed = params[:breed]
    # petfinder = Petfinder::Client.new(ENV["PETFINDER_API_KEY"], ENV["PETFINDER_SECRET_KEY"])
    # @pets = petfinder.find_pets('dog', 29601, breed: "#{@breed}", age: "Adult", count: 25)

    # page: 1
    # limit[]: 40
    # status: adoptable
    # token: 8o7sNKRqv4d_nHZLAhZ5AWJV6rq1MTxCo8r5WYjFKOo
    # distance[]: 100
    # type[]: dogs
    # sort[]: nearest
    # age[]: Adult
    # age[]: Senior
    # breed[]: Labrador Retriever
    # color[]: Black
    # location_slug[]: us/sc/greenville

    request = HTTParty.get("https://www.petfinder.com/search/?page=1&limit[]=40&status=adoptable&distance[]=10&type[]=dogs&sort[]=nearest&age[]=Adult&age[]=Senior&breed[]=#{@breed}&color[]=Black&location_slug[]=us%2Fsc%2Fgreenville",
      {headers: {"Content-Type" => "application/json", "x-requested-with" => "XMLHttpRequest"}
    })

    @pets = request["result"]["animals"]


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
