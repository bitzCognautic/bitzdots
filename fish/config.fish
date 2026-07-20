if status is-interactive
    set -g fish_greeting
    fastfetch
end

fish_add_path ~/.cargo/bin
fish_add_path ~/.local/bin

alias ytdlpmp3='mkdir -p ~/Musics; yt-dlp -x --audio-format mp3 --audio-quality 0 -o ~/Musics/"%(title)s.%(ext)s"'
alias ytdlpmp4='mkdir -p ~/Musics; yt-dlp -f "bestvideo+bestaudio" --merge-output-format mp4 -o ~/Musics/"%(title)s.%(ext)s"'
