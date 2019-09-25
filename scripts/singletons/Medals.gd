extends Node

"""
	Keep track of the medals in game
"""

var medals_data = {
	58134:false,
	58135:false,
	58136:false,
	58132:false
}

#true when verified the medals on newgrounds server
var checked_medals = false

#check the medals the player has on newgrounds server
func check_medals(newgrounds_api):
	checked_medals = true
	
	newgrounds_api.Medal.getList()
	var result = yield(newgrounds_api, 'ng_request_complete')
	if newgrounds_api.is_ok(result):
		var medals = result.response
		if medals['medals'][0].keys().find('unlocked') != -1:
			#the player is logged, lets check everything
			for medal in range(medals_data.keys().size()):
				medals_data[int(medals['medals'][medal]['id'])] = medals['medals'][medal]['unlocked']
	else:
		print(result.error)
	
#unlock medal by id
func unlock(id,newgrounds_api):
	if medals_data[id] == true:
		#medal already unlocked
		return
	
	medals_data[id] = true
	
	#unlock on newgrounds
	newgrounds_api.Medal.unlock(id)
	var result = yield(newgrounds_api, 'ng_request_complete')
	if newgrounds_api.is_ok(result):
		print(result.response)
	else:
		print(result.error)


