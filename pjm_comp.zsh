_pjm() {
    local projects=("$PROJECTS_DIR"/*(/:t))
    [[ ${#words} -eq 1 ]] && return;
    if [[ ${#words[2]} -eq 0 ]]; then
        local ta=("+" "-" "/" "h" "l")
        compadd "${ta[@]}"
        return
    fi
    local p="${words[2][1]}"
    case "$p" in 
        /|-) compadd -P $p "${projects[@]}"; ;;
        +) return; ;;
        h) return 1; ;;
        l)
            [[ ${#words} -eq 2 ]] && return;
            [[ $CURRENT -eq 2 ]] && compadd -P "l" "${projects[@]}" || compadd "${projects[@]}"; ;;
    esac
}
compdef _pjm pjm
