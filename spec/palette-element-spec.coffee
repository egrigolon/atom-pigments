Color = require '../lib/color'
Palette = require '../lib/palette'
{change} = require './helpers/events'

describe 'PaletteElement', ->
  [palette, paletteElement, workspaceElement, pigments, project] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    atom.config.set 'pigments.sourceNames', [
      '*.styl'
      '*.less'
    ]

    waitsForPromise -> atom.packages.activatePackage('pigments').then (pkg) ->
      pigments = pkg.mainModule
      project = pigments.getProject()

    waitsForPromise -> project.initialize()

  describe 'as a view provider', ->
    beforeEach ->
      palette = new Palette
        red: new Color '#ff0000'
        green: new Color '#00ff00'
        blue: new Color '#0000ff'
        redCopy: new Color '#ff0000'

      paletteElement = atom.views.getView(palette)

    it 'is associated with the Palette model', ->
      expect(paletteElement).toBeDefined()

  describe 'when pigments:show-palette commands is triggered', ->
    beforeEach ->
      atom.commands.dispatch(workspaceElement, 'pigments:show-palette')

      waitsFor ->
        paletteElement = workspaceElement.querySelector('pigments-palette')

      runs ->
        palette = paletteElement.getModel()

    it 'opens a palette element', ->
      expect(paletteElement).toBeDefined()

    it 'creates as many list item as there is colors in the project', ->
      expect(paletteElement.querySelectorAll('li').length).not.toEqual(0)
      expect(paletteElement.querySelectorAll('li').length).toEqual(palette.tuple().length)

    it 'binds colors with project variables', ->
      projectVariables = project.getColorVariables()

      li = paletteElement.querySelector('li')
      expect(li.querySelector('.path').textContent).toEqual(atom.project.relativize(projectVariables[0].path))

    describe 'when the sortPaletteColors settings is set to color', ->
      beforeEach ->
        atom.config.set 'pigments.sortPaletteColors', 'by color'

      it 'reorders the colors', ->
        sortedColors = project.getPalette().sortedByColor()
        lis = paletteElement.querySelectorAll('li')

        for [name,color],i in sortedColors
          expect(lis[i].querySelector('.name').textContent).toEqual(name)

    describe 'when the sortPaletteColors settings is set to name', ->
      beforeEach ->
        atom.config.set 'pigments.sortPaletteColors', 'by name'

      it 'reorders the colors', ->
        sortedColors = project.getPalette().sortedByName()
        lis = paletteElement.querySelectorAll('li')

        for [name,color],i in sortedColors
          expect(lis[i].querySelector('.name').textContent).toEqual(name)

    describe 'sorting selector', ->
      [sortSelect] = []

      describe 'when changed', ->
        beforeEach ->
          sortSelect = paletteElement.querySelector('#sort-palette-colors')
          sortSelect.querySelector('option[value="by name"]').setAttribute('selected', 'selected')

          change(sortSelect)

        it 'changes the settings value', ->
          expect(atom.config.get('pigments.sortPaletteColors')).toEqual('by name')