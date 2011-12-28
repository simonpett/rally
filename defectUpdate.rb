########################################################################
# Move a csv list of defects from a src project to a dest project
########################################################################
require 'rally_rest_api'
require 'date'
require 'logger'

puts RUBY_VERSION

user_name = ARGV[0]
password = ARGV[1]
workspace_name = ARGV[2]
src_project_name = ARGV[3]
dest_project_name = ARGV[4]

base_url = "https://rally1.rallydev.com/slm"
if ARGV[5] != nil
  base_url = ARGV[4]
end

if ( ARGV[0] == nil or ARGV[1] == nil or ARGV[2] == nil or ARGV[3] == nil )
  puts "Usage"
  puts "ruby query_revisions.rb username password workspace_name src_project_name dest_project_name"
  puts "Workspace and/or Project names with spaces need to be enclosed by quotes"
  exit
end

my_logger = Logger.new STDOUT

# Login to the Rally app
rally = RallyRestAPI.new(:base_url => base_url,
  :username => user_name, :password => password)
# , :logger => my_logger)

# Find workspace
workspace = rally.user.subscription.workspaces.find { |w| w.name == workspace_name }
if workspace == nil
  print "Workspace: " + workspace_name + " not found\n"
  return
end
print "Found Workspace: " + workspace.name + "\n"

# Find source project
src_project = src_project = workspace.projects.find { |p| p.name == src_project_name }
if src_project == nil
  print "Src Project: " + src_project_name + " not found\n"
  return
end
print "Found Src Project: " + src_project.name + "\n"

# Find destination project
dest_project = dest_project = workspace.projects.find { |p| p.name == dest_project_name }
if dest_project == nil
  print "Dest Project: " + dest_project_name + " not found\n"
  return
end
print "Found Dest Project: " + dest_project.name + "\n"

# Find defects in a specific project in Rally
defects = rally.find(:defects, :workspace => workspace, :project => src_project, :fetch => true) {equal :formatted_i_d, "DE3604"}


# Iterate through each defect and list the name
defects.each { |defect|
    puts "Defcet Description: #{defect.name}"
    puts "Defect Project #{defect.project}"
    puts "Defect #{defect.formatted_i_d}"
    defect.update(:project => dest_project)    
    puts "Defect Project #{defect.project}"
}