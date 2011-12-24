########################################################################
# This example shows how to query revisions on a set of tasks and search for a specific
# string in the description of the revision. The description is a plain text field and does not 
# include a back pointer to the Rally artifact. You will need to parse the text for the formatted id of 
# the object to determine what" was added/removed (e.g. Task added to a Rally story) from the given artifact.
########################################################################
require 'rally_rest_api'
require 'date'

user_name = ARGV[0]
password = ARGV[1]
workspace_name = ARGV[2]
project_name = ARGV[3]

base_url = "https://rally1.rallydev.com/slm"
if ARGV[4] != nil
  base_url = ARGV[4]
end

if ( ARGV[0] == nil or ARGV[1] == nil or ARGV[2] == nil or ARGV[3] == nil )
  puts "Usage"
  puts "ruby query_revisions.rb username password workspace_name project_name"
  puts "Workspace and/or Project names with spaces need to be enclosed by quotes"
  exit
end

# Login to the Rally app
rally = RallyRestAPI.new(:base_url => base_url,
  :username => user_name, :password => password)

# Find workspace
workspace = rally.user.subscription.workspaces.find { |w| w.name == workspace_name }
if workspace == nil
  print "Workspace: " + workspace_name + " not found\n"
  return
end
print "Found Workspace: " + workspace.name + "\n"

# Find project
project = project = workspace.projects.find { |p| p.name == project_name }
if project == nil
  print "Project: " + project_name + " not found\n"
  return
end
print "Found Project: " + project.name + "\n"

# Find tasks in a specific project in Rally and tasks in a defined state
tasks = rally.find(:task, :workspace => workspace, :project => project, :fetch => true) {equal :State, "Defined"}

# Iterate through each task and load the revisions
# RevisionHistory is a collection of Revision objects
tasks.each { |task|
  # Put revisions in date order earliest to latest
  sorted_revs = task.revision_history.revisions.sort {|x, y| x.creation_date <=> y.creation_date}

  # Search for revisions with the text "TO DO"
  sorted_revs.each { |revision|
    puts "Revision Description: #{revision.description}"
    if ( revision.description.include?("TO DO"))
      puts "Task includes TO DO in revisions"
    end
  }
}