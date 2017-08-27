#### Command Injection

> Do not use in web app or ensure 100% its not injectable if completely necessary
```ruby
eval("ruby code here")
System("os command here")
`ls -al /`   (backticks contain os command)
Kernel.exec("os command here")
open("| os command here")
```

#### SQL Injection

```ruby
username = "admin' OR 1); -- "
password = ""
user = User.find_by("username = '#{username}' AND password = '#{password}'")
```

```sql
SELECT  "users".* FROM "users" WHERE (username = 'admin' OR 1); -- ' AND password = '') LIMIT 1 
```

**Solution**
```ruby
user = User.find_by('username = ? AND password = ?', params[:username], params[:password])

user.find_by(username: params[:username], password: params[:password]).first
```

> notice `?` it escapes to ensure it cannot be injectable
```sql
SELECT  "users".* FROM "users" WHERE (username = 'admin'' OR 1); -- ' AND password = '') LIMIT 1
```

#### Cross-site Scripting (XSS)

> Use caution when using these

```erb
<!--This method outputs without escaping a string-->
<%= raw "<script>alert('raw does not escape input!!')</script>" %>

<!--equivalent to raw method-->
<%= "<script>alert('html_safe does not escape input!!')</script>".html_safe %>

<!--content_tag does not escape-->
<%= content_tag "<script>alert('content_tag does not escape input!!')</script>" %>

```
**Ensure that links do not take user inputted data**
```erb
<%= link_to 'Personal Website', "javascript:alert('links not so safe either :(')" %>
```
**link returns**
```html
<a href="javascript:alert('links not so safe either :(')">Personal Website</a>
```

#### Session Guidelines
 - Do not store large objects in a session.
 - Use object references only preferably GUIDs
 - Critical data should not be stored in session. to allow us to clear sessions without issue

**Force SSL**
 ```ruby
config.force_ssl = true
```

**Use database session management**
```ruby
Project::Application.config.session_store :active_record_store
```

**Encrypted Cookie Store**
- store keys in a password vault and not in code

```yaml
development:
  secret_key_base: a75d...
 
test:
  secret_key_base: 492f...
 
production:
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
```

**Session Fixation - Countermeasures**

`reset_session` or Devise gem

**Session Expiry**
```ruby
class Session < ApplicationRecord
  def self.sweep(time = 1.hour)
    if time.is_a?(String)
      time = time.split.inject { |count, unit| count.to_i.send(unit) }
    end
 
    delete_all "updated_at < '#{time.ago.to_s(:db)}' OR
  created_at < '#{2.days.ago.to_s(:db)}'"
  end
end
```

**Cross-Site Request Forgery (CSRF)**

```ruby
protect_from_forgery with: :exception
```

Use `GET` if:
> The interaction is more like a question (i.e., it is a safe operation such as a query, read operation, or lookup).


otherwise use `POST`

**Redirection**
> just do not redirect user inputted/changeable links

```ruby
def legacy
  redirect_to(params.update(action:'main'))
end
```

**File Uploads**
- sanitize filename
- ensure OS is using appropriate permissions
- async uploads to prevent DOS

```ruby
def sanitize_filename(filename)
  filename.strip.tap do |name|
    # NOTE: File.basename doesn't work right with Windows paths on Unix
    # get only the filename, not the whole path
    name.sub! /\A.*(\\|\/)/, ''
    # Finally, replace all non alphanumeric, underscore
    # or periods with underscore
    name.gsub! /[^\w\.\-]/, '_'
  end
end
```

**File Downloads**

```ruby
send_file('/var/www/uploads/' + params[:filename])
```
> ensures requested file is in the expect directory

```ruby
basename = File.expand_path(File.join(File.dirname(__FILE__), '../../files'))
filename = File.expand_path(File.join(basename, @file.public_filename))
raise if basename !=
     File.expand_path(File.join(File.dirname(filename), '../../../'))
send_file filename, disposition: 'inline'
```

**Brute-Forcing Accounts**

- display a generic error message on forgot-password pages
- CAPTCHA after a number of failed logins from a certain IP address

- SALT passwords

**Logging**
- remove any sensitive data
- audit

`config.filter_parameters << :password`
