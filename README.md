# Chute
Chute is a simple ruby script that facilitates the text-based build systems. Each command performs a transformation on a file or collection of files then passed to the next chainable command. Build scripts are specified in a `chutespec.rb` file that is selected when running `chute` in the current directory.

## Example

This script will build a file called main.styl, concatenate the resulting build with any raw css files, save the result as `style.css`, minify the result using `cleancss`, then save the minified result as `style.min.css`.

```ruby
# chutespec.rb

stylus = Chute::file('main.styl')
css = Chute::glob('*.css')

stylus
  .pipe('stylus')
  .merge(css)
  .concat()
  .save_as('style.css')
  .pipe('cleancss')
  .save_as('style.min.css')
```

- Chute::glob(glob)
  - Creates an entity set based on the given glob pattern
- Chute::file(path)
  - Creates a entity set from a specified file
- merge(*entity_sets)
  - Merges multiple entity sets into one
- concat(path = null)
  - Concatenates the contents of multiple entity sets into one. The path of the resulting set can be optionally set.
- replace(from, to)
  - Replace a given string or regex in all entities.
- do(&block)
  - Passes each entity in a set to a given block. Entities have the mutable properties `contents` and `path`.
- extension(ext)
  - Changes the extension of each entity in the set.
- save()
  - Saves each entity to their current path.
- save_as(path)
  - Saves a single entity to the given path
- cd(path)
  - Changes the `cwd`
- pipe(command, *args)
  - Passes the contents of each entity to a shell command and replaces the contents with the resulting stdout.
