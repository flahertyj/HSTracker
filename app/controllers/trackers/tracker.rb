class Tracker < NSWindowController

  def windowWillMiniaturize(_)
    window.setLevel(NSNormalWindowLevel)
  end

  def windowDidMiniaturize(_)
    window.setLevel(NSScreenSaverWindowLevel)
  end

  def windowDidMove(_)
    save_frame
  end

  def windowDidResize(_)
    save_frame
  end

  def save_frame
    return if Configuration.windows_locked
    NSUserDefaults.standardUserDefaults.setObject(NSStringFromRect(self.window.frame),
                                                  forKey: self.window.identifier)
  end

  def window_locks
    locked = Configuration.windows_locked

    if locked
      mask = NSBorderlessWindowMask
    else
      mask = NSTitledWindowMask | NSResizableWindowMask | NSBorderlessWindowMask
    end
    self.window.setStyleMask mask
  end

  def window_transparency
  end

  def showWindow(sender)
    # trigger when loading the window
    super.tap do
      @option_changed = NSNotificationCenter.defaultCenter.observe 'windows_locked' do |notification|
        window_locks
      end
      @transparency_changed = NSNotificationCenter.defaultCenter.observe 'window_transparency' do |notification|
        window_transparency
      end
    end
  end

  def windowWillClose(_)
    NSNotificationCenter.defaultCenter.unobserve(@option_changed)
    NSNotificationCenter.defaultCenter.unobserve(@transparency_changed)
  end
end