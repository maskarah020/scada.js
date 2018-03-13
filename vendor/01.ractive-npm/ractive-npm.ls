require! 'ractive': Ractive
# Add Ractive to global window object
# ---------------------------------------------
window.Ractive = Ractive


sleep = (ms, f) -> set-timeout f, ms

# Add modal support by default
require! 'ractive-modal': RactiveModal
Ractive.components.modal = RactiveModal

# Helper methods
# ---------------------------------------------

# DEPRECATED
Ractive.defaults.has-event = (event-name) ->
    console.warn "Deprecated: Use ractive.hasListener"
    fn = (a) ->
        a.t is 70 and a.n.indexOf(event-name) > -1
    return @component and @component.template.m.find fn

# hasAttribute by @evs-chris
# see the example: https://ractive.js.org/playground/?env=docs#N4IgFiBcoE5SBTAJgcwSAvgGhAZ3gGYCuAdgMYAuAlgPYkAEYAhrgIIUUxUBGRFCACmD0ADjBoUa9DAEp6wADokFFMRJoA6Zmw5de-egF56xctTqMW7Tjz6CSTALYI5i5RRUwEFIjAYUwKlwNMhpHEToEEgp6ADJY+gEBAKCQsIiSKIoNfnCAGyZ+DSY4hIdneip-QODQ8MjonIR8woRiuQAfDsSU2vSG7NyRAqLHUvoAQgnetPrMxqGRtscNAiqkARLDAD56Jg0GQyP6cpcZGQBuJRUMJVvlEgAlJkoqADc2olxBbWs9O0u1yeL2oH1mGSywQINCkxmerzBCAAHvwSBs3CpFq1IPQAAbXDwUAA8Im2wGA21C0SyGAwRmOBJUKnJAGIqAR6AABLRWXS2fgCADkSMFMlpjMJKgAEqwAMr0AAa9FYABUVY8AJIAIQAqiqAKL0XUq+gAOQA8ibZfqVRLmcAEHlvuL3EzCVKWCcpEi9nz9AhfXs8nk7RRyQB6dm0onh0kS3FYAlIQpMHGmV50AQyDGErw+PzyUNInEkIjBiX3G53GRKTIAd3o8NBghzjpxgu4NCQAE9BYn3Fj+Dj8a7idDvYYFCBydwmDBxSB6NsZfKlar1dq9YbjWbLfRrSqY+PthKicePbgvfQfYUbP7A0xg0eYSf3AmkymcTmVLOYDjSEgCBrJkSAEvcsiYEAA
/* requires ractive edge for now */
``
function hasAttribute({ proto }) {
	proto.hasAttribute = function hasAttribute(name) {
		return this.component && ((this.component.template.a && name in this.component.template.a) || (this.component.template.m && !!this.component.template.m.find(a => a.n === name)));
	}
}

Ractive.use(hasAttribute);
``
/**/

# by @evs-chris, https://gitter.im/ractivejs/ractive?at=59fa35f8d6c36fca31c4e427
Ractive.prototype.delete = (root, key) ->
    /***************************************************************************
    Usage:

        +each('curr.components') <--- where curr.components is an Object
            btn.icon(on-buttonclick="@.delete('curr.components', @key)") #[i.minus.icon]

    ***************************************************************************/
    console.error 'keypath must be string' if typeof! root isnt \String
    delete @get(root)[key]
    @update root

# Events
# ---------------------------------------------
Ractive.events.longpress = (node, fire) ->
    timer = null
    clear-timer = ->
        clear-timeout timer if timer
        timer := null

    mouseDownHandler = (event) ->
        clear-timer!

        timer = sleep 1000ms, ->
            fire {node: node, original: event}

    mouseUpHandler = -> clear-timer!

    node.addEventListener \mousedown, mouseDownHandler
    node.addEventListener \mouseup, mouseUpHandler

    return teardown: ->
        node.removeEventListener \mousedown, mouseDownHandler
        node.removeEventListener \mouseup, mouseUpHandler

# Context helpers
# ---------------------------------------------
Ractive.Context.find-keypath-id = (postfix='') ->
    /***************************************************************************
    Use to find a unique DOM element near the context

    Usage:

        1.  define a DOM element with a unique id:

            <div id="{{@keypath}}-mypostfix" > ... </div>

        2. Find this DOM element within the handler, using ctx:

            myhandler: (ctx) ->
                the-div = ctx.find-keypath-id '-mypostfix'

    ***************************************************************************/
    @ractive.find '#' + Ractive.escapeKey(@resolve!) + postfix

Ractive.Context.removeMe = ->
    /***************************************************************************
    usage:

        +each('something')
            btn.icon(on-buttonclick="@context.removeMe()") #[i.minus.icon]
    ***************************************************************************/

    @splice '..', @get('@index'), 1
