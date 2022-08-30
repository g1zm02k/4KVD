This is a simple script to give 4K Video Downloader a bit more functionality while using it as a replacement for JDownloader2 until they fix the YouTube download speed issue.

It adds a basic clipboard monitor for YouTube links (i.e. right-click a link and copy), and it'll rename the video files once downloaded with the channel name before the title so there's some semblance of order.

It was written in a hurry and is by no means perfect. It's just for personal use but feel free to change it up for your own purposes.

Requires [AutoHotkey](https://www.autohotkey.com/)

Fixes for 1.5:

* What I thought I'd fixed in 1.4
* Fixed an continually added empty array every second.
* Increased download check time to 2s (as a double check for fix above). 

Fixes for 1.4:

* Big rewrite to catch YT links anywhere on the clipboard.
* Now catches multiple links in one clip.
* Skips duplicates that are currently downloading.
* Catches YouTu.be links.
* Now renames Shorts too.
