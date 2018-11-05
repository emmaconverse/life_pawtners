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
      @result = visual_recognition.classify(
        images_file: image,
        threshold: 0,
        classifier_ids: ["default"]
      ).result["images"][0]["classifiers"][0]["classes"]

# need to determin animal type
      # @cat = result.select { |result|
      #   result["class"].include? "cat"
      # }

      # @animal_type = if result.select { |result| result["class"].include? "dog" }
      #                 "dogs"
      #                 if result.select { |result| result["class"].include? "cat" }
      #                   "cats"
      #                 end
      #               end

      @animal_type = @result.any? { |result| result["class"].include? "dog" } ? "dogs" : "cats"

      # if_this_is_a_true_value ? then_the_result_is_this : else_it_is_this



      @sorted_classes = remove_banned_class_names(@result).sort_by { |hash| hash["score"] }

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

      # age_result = visual_recognition.classify(
      #   images_file: image,
      #   threshold: 0.6,
      #   owners: ["me"]
      # ).result["images"][0]["classifiers"][0]["classes"]

    end
    byebug
    redirect_to homes_path(breed: @breed, color: @color, animal_type: @animal_type)
  end


  def index
    @breed = params[:breed]
    @color = params[:color]
    @animal_type = params[:animal_type]

    request = HTTParty.get("https://www.petfinder.com/search/?page=1&limit[]=40&status=adoptable&distance[]=1000&type[]=#{@animal_type}&sort[]=nearest&age[]=Young&age[]=Baby&age[]=Adult&age[]=Senior&breed[]=#{@breed}&#{@color}[]=Golden&location_slug[]=us%2Fsc%2Fgreenville",
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
    ["cat", "canine", "puppy", "kitten", "feline", "dog", "carnivore", "mammal", "animal", "domestic animal"]
  end

  def determine_color(color)
    COLOR_MAP[color] || ""
  end

  def determine_animal_type(animal)
  end
end
