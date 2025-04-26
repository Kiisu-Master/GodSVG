use std::borrow::Cow;

use arboard::{Clipboard, ImageData};
use godot::classes::{IRefCounted, Image, RefCounted, image::Format};
use godot::prelude::*;

struct MyExtension;

#[gdextension]
unsafe impl ExtensionLibrary for MyExtension {}

#[derive(GodotClass)]
#[class(base=RefCounted)]
struct Ext {
    clipboard: Result<Clipboard, arboard::Error>,
    base: Base<RefCounted>,
}

#[godot_api]
impl IRefCounted for Ext {
    fn init(base: Base<RefCounted>) -> Self {
        Self {
            clipboard: Clipboard::new(),
            base,
        }
    }
}

#[godot_api]
impl Ext {
    #[func]
    fn clip_set_image(&mut self, mut image: Gd<Image>) -> godot::global::Error {
        if let Ok(clip) = &mut self.clipboard {
            image.convert(Format::RGBA8);
            let data = image.get_data();
            let bytes = data.as_slice();
            let height = image.get_height() as usize;
            let width = image.get_width() as usize;
            let img_data = ImageData {
                bytes: Cow::from(bytes.as_ref()),
                width,
                height,
            };
            match clip.set_image(img_data) {
                Err(_) => return godot::global::Error::OK,
                Ok(_) => return godot::global::Error::FAILED,
            };
        } else {
            return godot::global::Error::FAILED;
        }
    }
}
