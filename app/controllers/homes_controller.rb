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

# need to determin animal type
      @cat = result.select { |x|
        x["class"].include? "cat"
      }

      @dog = result.select { |y|
        y["class"].include? "dog"
      }


      @sorted_classes = remove_banned_class_names(result).sort_by { |hash| hash["score"] }

      @breed = @sorted_classes.reject { |result|
                result["class"].include? "color"
              }.take(2).map { |breed|
                breed["class"].remove(" dog")
              }.first.try :titleize

      @watson_color = @sorted_classes.select { |result|
                      result["class"].include? "color"
                    }.max_by { |result|
                      result["score"] }

      @color = determine_color(@watson_color["class"])


      #
      # need to include cat?

      # @color = determine_color(@watson_color)


      # @breed = @sorted_classes.reject { |result|
      #   result["class"].include? "color"
      # }.take(2).map { |breed|
      #   breed["class"].remove(" dog")
      # }.take(2).map { |breed|
      #   breed["class"].remove(" cat")
      # }.first.try(:titleize)


      # @colors = @sorted_classes.reject { |result|
      #   result["class"].include? "dog"
      # }.reject { |result|
      #   result["class"].include? "cat"
      # }.map { |color|
      #   color["class"].remove("light ")
      # }.map { |color|
      #   color["class"].remove("dark ")
      # }.take(2)



      # age_result = visual_recognition.classify(
      #   images_file: image,
      #   threshold: 0.6,
      #   owners: ["me"]
      # ).result["images"][0]["classifiers"][0]["classes"]

    end

    redirect_to homes_path(breed: @breed, color: @color)
  end


  def index
    @breed = params[:breed]
    @color = params[:color]

    request = HTTParty.get("https://www.petfinder.com/search/?page=1&limit[]=40&status=adoptable&distance[]=1000&type[]=dogs&sort[]=nearest&age[]=Adult&age[]=Senior&breed[]=#{@breed}&#{@color}[]=Golden&location_slug[]=us%2Fsc%2Fgreenville",
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



end





    # page: 1
    # limit[]: 40
    # status: adoptable
    # token: 8o7sNKRqv4d_nHZLAhZ5AWJV6rq1MTxCo8r5WYjFKOo
    # distance[]: 100
    # type[]: dogs
    # sort[]: nearest
    # age[]: Adult (Puppy)
    # age[]: Senior (Young)
    # breed[]: Labrador Retriever
    # color[]: Black
    # location_slug[]: us/sc/greenville




# Apricot / Beige
# Bicolor
# Black
# Brindle
# Brown / Chocolate
# Golden
# Gray / Blue / Silver
# Harlequin
# Merle (Blue)
# Merle (Red)
# Red / Chestnut / Orange
# Sable
# Tricolor (Brown, Black, & White)
# White / Cream
# Yellow / Tan / Blond / Fawn
