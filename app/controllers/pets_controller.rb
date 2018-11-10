require "ibm_watson/visual_recognition_v3"
require "httparty"
require 'will_paginate/array'

class PetsController < ApplicationController

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

      @animal_type = result.any? { |result| result["class"].include? "dog" } ? "dogs" : "cats"
      @sorted_classes = remove_banned_class_names(result).sort_by { |hash| hash["score"] }
      @breed = @sorted_classes.reject { |result|
                result["class"].include? "color"
              }.take(2).map { |breed|
                breed["class"].remove(" dog", " cat", "-dog", "-cat", "(dog)", "(cat")
              }.first.try :titleize
      @watson_color = @sorted_classes.select { |result|
                      result["class"].include? "color"
                    }.map { |color| color["class"].remove("light ", "dark ", " color")
                    }.max_by { |result|
                      result["score"] }
      @color = determine_color(@watson_color)

      @age_result = visual_recognition.classify(
        images_file: image,
        threshold: 0.5,
        owners: ["me"]
      ).result["images"][0]["classifiers"][0]["classes"]

        @animal_age = @age_result.any? { |result| result["class"].include? "adult_dog" || "adult_cat" } ? ["Adult", "Senior"] : ["Baby", "Young"]

    end
    redirect_to pets_path(breed: @breed, color: @color, animal_type: @animal_type, animal_age: @animal_age)
  end


  def index
    @breed = params[:breed]
    @color = params[:color]
    @animal_type = params[:animal_type]
    @animal_age = params[:animal_age]


    request = HTTParty.get("https://www.petfinder.com/search/?page=#{params[:page] || 1}&limit[]=15&status=adoptable&distance[]=100&type[]=#{@animal_type}&sort[]=nearest&age[]=#{@animal_age[0]}&age[]=#{@animal_age[1]}&breed[]=#{@breed}&color[]=#{@color}&location_slug[]=us%2Fsc%2Fgreenville",
      {headers: {"Content-Type" => "application/json", "x-requested-with" => "XMLHttpRequest"}
    })

    @pets = request["result"]["animals"]

    @locations = {}
    @grouped_pets = @pets.group_by{ |pet| pet["location"]["geo"]["latitude"].to_s + "," + pet["location"]["geo"]["longitude"].to_s }.keys.each {|key| @locations[key] = [] }
    @pushed_pets = @pets.each { |pet| key = (key = pet["location"]["geo"]["latitude"].to_s + "," + pet["location"]["geo"]["longitude"].to_s), @locations[key].push(pet) }
    @animals_at_location = @locations.map { |key, values| values.map { |value| value["animal"] }}
    # @lat_long = @locations.map { |key, values| values.map { |value| value["location"]["geo"] }}


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
    ["cat", "canine", "puppy", "kitten", "feline", "dog", "carnivore", "mammal", "animal", "domestic animal"]
  end

  def determine_color(color)
    COLOR_MAP[color] || ""
  end

  # def animal_name_by_location(location)
  #   location.map { |key, values| values.map { |value| value["animal"]["name"] }}
  # end

end
