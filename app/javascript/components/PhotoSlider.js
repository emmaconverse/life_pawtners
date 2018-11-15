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
      {this.props.photos.map((photo)=>
        <div key={photo}>
          <img src={photo} height={500}/>
        </div>
      )}

      </Slider>
    );
  }
}

export default PhotoSlider;
