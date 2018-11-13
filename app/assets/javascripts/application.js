// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require rails-ujs
//= require activestorage
//= require_tree .

$(document).ready(function(){
  $('.button-pet-details').click(function(e) {
    //E.PREVENTdEFAULT prevents the browser from going to top of page every time something is clicked
    e.preventDefault();

    // var idForLookup = $(this).attr('data-id');
    $("[data-modal=" + $(this).attr('data-id') + "]").removeClass('hidden');
  });

  // $(`.pet-details[data-id='${idForLookup}']`).toggleClass('active');
  $('.close').click(function() {
    $('.pet-details--container').addClass('hidden');
  })
});

// $(document).ready(function(){
//   $('.next').click(function(e) {
//     //E.PREVENTdEFAULT prevents the browser from going to top of page every time something is clicked
//     e.preventDefault();

//     $("[data-modal=" + $(this).attr('data-id') + "]").removeClass('hidden');
//   });

//   $('.close').click(function() {
//     $('.pet-details').addClass('hidden');
//   })
// });

var map;


function initMap() {
  map = new google.maps.Map(document.getElementById('map'), {
    center: {lat: 34.8526, lng: -82.3940},
    zoom: 8
  });

  var infoWindows = []

  Object.keys(locations).forEach(function(location) {

    var lat = location.split(",").shift();
    var lng = location.split(",").pop();
    var position = new google.maps.LatLng(parseFloat(lat), parseFloat(lng));
    var marker = new google.maps.Marker({
      position: position,
      map: map
      });

    var renderAnimalInfo = locations[location].map(function(animalInfo) {

      var animal = animalInfo.animal;
      var animalList =
        `
        <div class="pet-avatar-container">
          <img src="${animal.primary_photo_cropped_url}" height="100">
        </div>
        <h5>${animal.name}</h5>
        <ul>
          <li>${animal.age}</li>
          <li>${animal.sex}</li>
          <li>${animal.breeds_label}</li>
        </ul>
        `;
                                          // ${animal.photo_urls.map(photo =>
                                          //             `<img src="${photo}" height="100">`)}
                                          // ${keywords.map(keyword => `<li>${keyword}</li>`)}
      return animalList
    });

    var infoWindow = new google.maps.InfoWindow({
      content: `${renderAnimalInfo}`
    });

    infoWindows.push(infoWindow)

    marker.addListener('mouseover', function() {
      infoWindows.forEach(function(infoWindow) {
        infoWindow.close()
      })
      infoWindow.open(map, marker);
    });
  });
};



// <%= react_component("PhotoSlider", {
//     books: Book.all
//   }) %>
