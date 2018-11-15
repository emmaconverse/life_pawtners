import React from "react";
import Slider from "react-slick";

class PhotoSlider extends React.Component {
  render() {
    var settings = {
      dots: true,
      infinite: true,
      speed: 500,
      slidesToShow: 1,
      slidesToScroll: 1
    };
    console.log(this.props)
    return (
      <Slider {...settings}>
      {this.props.photos.map((photo)=> <img key={photo} src={photo} height={500} /> )}
      </Slider>
    );
  }
}

export default PhotoSlider;
