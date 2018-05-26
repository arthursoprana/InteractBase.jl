for op in [:filepicker, :autocomplete, :input, :dropdown, :checkbox, :toggle,
           :textbox, :button, :slider, :radio, :radiobuttons, :togglebuttons, :tabs,
           :wrap, :wdglabel,
           :manipulateinnercontainer, :manipulateoutercontainer]
    @eval begin
        function $op(args...; kwargs...)
            length(args) > 0 && args[1] isa WidgetTheme &&
                error("Function " * string($op) * " was about to overflow: check the signature")
            $op(gettheme(), args...; kwargs...)
        end
    end
end
