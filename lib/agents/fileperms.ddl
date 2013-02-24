metadata	:name		 => "",
			:description => "",
			:author		 => "",
			:license	 => "MIT",
			:version	 => "1.0.0",
			:url		 => "www.terc.edu",
			:timeout	 => 5
[ "chown", "chgrp", "chmod" ].each do |act|
  action act, :description => "Equivalent to executing a #{act}" do
    input :path,
		  :prompt		=> "Path to file or directory",
		  :description	=> "Argument to command",
		  :type			=> :string,
		  :validation	=> '^.+$',
		  :optional		=> false,
		  :maxlength	=> 256
			
    input :owner,
          :prompt		=> "UID or name of owner",
		  :description	=> "Argument to command",
		  :type			=> :string,
		  :validation	=> '^.+$',
		  :optional		=> true,
		  :maxlength	=> 256
	
	input :group,
          :prompt		=> "GID or name of group",
		  :description	=> "Argument to command",
		  :type			=> :string,
		  :validation	=> '^.+$',
		  :optional		=> true,
		  :maxlength	=> 256
    
    input :mode,
          :prompt		=> "Permissions mode",
		  :description	=> "Argument to command",
		  :type			=> :string,
		  :validation	=> '^.+$',
		  :optional		=> true,
		  :maxlength	=> 256
	
	input :recurse,
          :prompt		=> "Recursive?",
		  :description	=> "Argument to command",
		  :type			=> :boolean,
		  :optional		=> true
		  
    output :output,
		   :description	=> "Human readable information about the outcome of the operation",
		   :display_as	=> "Status"			  
  end
end
