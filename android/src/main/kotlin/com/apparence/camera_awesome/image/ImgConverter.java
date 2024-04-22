package com.apparence.camera_awesome.image;

import android.media.Image;
import android.media.ImageReader;

public interface ImgConverter {

    byte[] process(ImageReader imageReader);
}
