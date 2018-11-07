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
  $('.pet-info-button').click(function(e) {
    //E.PREVENTdEFAULT prevents the browser from going to top of page every time something is clicked
    e.preventDefault();
    // var idForLookup = $(this).attr('data-id');
    $('.pet-details').removeClass('hidden');
    // $(`.pet-details[data-id='${idForLookup}']`).toggleClass('active');
  });
  $('.close').click(function() {
    $('.pet-details').addClass('hidden');
  })
});
