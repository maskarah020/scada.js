require! 'aea': {merge, sleep}
require! 'dcs/browser': {Signal}

Ractive.components['ack-button'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        if @get \class .index-of(\transparent)  > -1
            @set \transparent, yes

    onrender: ->
        __ = @
        @doing-watchdog = new Signal!
        # logger utility is defined here
        logger = @root.find-component \logger
        console.error "No logger component is found!" unless logger
        # end of logger utility

        @button-timeout = if @get \timeout
            that
        else
            10_000ms

        @observe \tooltip, (new-val) ->
            __.set \reason, new-val

        @on do
            click: ->
                val = __.get \value
                # TODO: remove {args: val}
                @fire \buttonclick, val

            state: (_event, s, msg, callback) ->
                self-disabled = no

                if s in <[ done ]>
                    __.set \state, \done

                if s in <[ done... ]>
                    __.set \state, \done
                    <- sleep 3000ms
                    if __.get(\state) is \done
                        __.set \state, ''

                if s in <[ done done... ]>
                    @doing-watchdog.go!

                if s in <[ normal ]>
                    @doing-watchdog.go!
                    __.set \state, \normal

                if s in <[ doing ]>
                    __.set \state, \doing
                    self-disabled = yes
                    reason <~ @doing-watchdog.wait @button-timeout
                    if reason is \timeout
                        __.fire \error, "button timed out!"
                    else
                        console.log "hey, watchdog fired successfully", @doing-watchdog

                __.set \selfDisabled, self-disabled

                if s in <[ error ]>
                    console.warn "scadajs: Deprecation: use \"ack-button.fire \\error\" instead"
                    @fire \error, msg, callback

            error: (_event, msg, callback) ~>
                @doing-watchdog.go!

                msg = try
                    {message: msg} unless msg.message
                catch
                    {message: "error in message! (internal error)"}
                msg = msg `merge` {
                    title: msg.title or 'This is my error'
                    icon: "warning sign"
                }
                action <~ logger.fire \showDimmed, msg, {-closable}

                __.set \state, \error
                __.set \reason, msg.message
                __.set \selfDisabled, no

                #console.log "error has been processed by ack-button, action is: #{action}"
                callback action if typeof! callback is \Function

            info: (_event, msg, callback) ->
                @doing-watchdog.go!
                msg = {message: msg} unless msg.message
                msg = msg `merge` {
                    title: msg.title or 'ack-button info'
                    icon: "info circle"
                }
                action <- logger.fire \showDimmed, msg, {-closable}
                #console.log "info has been processed by ack-button, action is: #{action}"
                callback action if typeof! callback is \Function

            yesno: (_event, msg, callback) ->
                @doing-watchdog.go!
                msg = {message: msg} unless msg.message
                msg = msg `merge` {
                    title: msg.title or 'Yes or No'
                    icon: "map signs"
                }
                action <- logger.fire \showDimmed, msg, {-closable, mode: \yesno}
                #console.log "yesno dialog has been processed by ack-button, action is: #{action}"
                callback action if typeof! callback is \Function
    onteardown: ->
        @doing-watchdog.go!
        
    data: ->
        __ = @
        reason: ''
        type: "default"
        value: ""
        class: ""
        style: ""
        disabled: no
        self-disabled: no
        enabled: yes
        state: ''
        on-done: ->
        transparent: no
