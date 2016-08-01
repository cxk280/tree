clas        = require 'classnames'

reactify    = require './Reactify.coffee'
query       = require './Async.coffee'

util        = require '../utils/util.coffee'

recl = React.createClass
{div,pre,span,a,ul,li,h1} = React.DOM

module.exports = query {
    path:'t'
    kids:
      snip:'r'
      head:'r'
      meta:'j'
      bump:'t'
      name:'t'
  }, recl
  displayName: "List"

  render: ->
    k = clas
      list: true
      @props.dataType
      default: @props['data-source'] is 'default'
      @props.className
    kids = @renderList @sortedKids()
    unless kids.length is 0 and @props.is404?
      return (ul {className:k}, kids)

    div {className:k},
      h1  {className:'red inverse block error'}, 'Error: Empty path'
      div {},
        pre  {}, @props.path
        span {}, 'is either empty or does not exist.'

  sortedKids: ->
    # check if kids all have a sort meta tag
    if @props.sortBy is 'bump'
      return _.sortBy(@props.kids,
        ({bump,name})-> bump || name
      ).reverse()

    sorted = true
    _kids = []
    for k,elem of @props.kids
      meta = elem.meta ? {}
      if @props.sortBy
        if @props.sortBy is 'date'
          if not meta.date?
            return _.sortBy(@props.kids,'name')
          _k = Number meta.date.slice(1).replace /\./g,""
          _kids[_k] = elem
      else
        if not meta.sort?
          return _.sortBy(@props.kids,'name')
        _kids[Number(meta.sort)] = elem
    if @props.sortBy is 'date' then _kids.reverse()
    _.values _kids
      
  renderList: (elems)->
    for elem in elems
      item = elem.name
      meta = elem.meta ? {}
      path = @props.path+"/"+item
      if meta.hide? then continue
      href = util.basepath path
      if @props.linkToFragments? then href="#"+item
      if @props.childIsFragment? then href=(util.basepath @props.path)+"#"+item
      if meta.link then href = meta.link
      parts = []
      title = null

      if meta.title
        if @props.dataType is 'post'
          title =
            gn: 'a'
            ga: {href}
            c: [
              gn: 'h1'
              ga: {className:'title'}
              c: [meta.title]
            ]
        else
          title =
            gn: 'h1'
            ga: {className:'title'}
            c: [meta.title]
      if not title && elem.head.c.length > 0
        title = elem.head
      if not title
        title =
          gn: 'h1'
          ga: {className:'title'}
          c: [item]

      unless @props.titlesOnly        # date
        _date = meta.date
        if not _date or _date.length is 0 then _date = ""
        date =
          gn: 'div'
          ga: {className: 'date'}
          c: [_date]
        parts.push date

      parts.push title

      unless @props.titlesOnly         # metadata
        if @props.dataType is 'post'
          if meta.image           # image
            image =
              gn: 'a'
              ga: {href}
              c: [
                gn: 'img'
                ga:
                  src: meta.image
              ]
            parts.push image
        if @props.dataPreview         # preview
          if not meta.preview
            parts.push (elem.snip.c.slice 0,2)...
          else
            if meta.preview
              preview =
                gn: 'p'
                ga: {className:'preview'}
                c: [meta.preview]
            else
              preview = elem.snip
            parts.push preview
        if @props.dataType is 'post'
          if meta.author          # author
              author =
                gn: 'h3'
                ga: {className:'author'}
                c: [meta.author]
              parts.push author
          cont =
            gn: 'a'
            ga: {className:'continue',href}
            c: ['Read more']
          parts.push cont
          linked = true

      node = reactify {gn:'div',c:parts}
      if not linked?
        node = (a {
            href
            className:(clas preview:@props.dataPreview?)
          },node)

      li {key:item},node
