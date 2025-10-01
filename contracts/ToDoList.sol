// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

contract ToDoList {

    enum State {
        SinHacer,
        Completado
    }

    struct Tarea {
        string description;
        uint256 creationTime;
        uint256 index;
        State state;
    }

    Tarea[] public tarea; // tarea[indice]
    uint256 private nextIndex;

    event TaskAdded(uint256 indexed index,string indexed description, uint256 creationTime);
    event TaskedStatusChanged(uint256 indexed index,string indexed description,string indexed newStatus);

    function setTarea(string calldata _description) external {
        uint256 _lastIndex = nextIndex++;
        tarea.push(Tarea(_description,block.timestamp,_lastIndex,State.SinHacer));
        emit TaskAdded(_lastIndex,_description, block.timestamp);
    }

    function getTareas() external view returns (Tarea[] memory) {
        return tarea;
    }

    function eliminarTarea(string calldata _descripcion) external {
        uint256 len = tarea.length;
        for(uint256 i; i<len;) {
            if(keccak256(bytes(tarea[i].description)) == keccak256(bytes(_descripcion))) {
                emit TaskedStatusChanged(tarea[i].index,tarea[i].description,"eliminado");
                tarea[i] = tarea[len-1];
                tarea.pop();
                break;
            }
            unchecked {
                ++i;
            }
        }
    }

    function completarTarea(string calldata _descripcion) external {
        uint256 len = tarea.length;
        for(uint256 i; i<len;) {
            if(keccak256(bytes(tarea[i].description)) == keccak256(bytes(_descripcion))) {
                emit TaskedStatusChanged(tarea[i].index,tarea[i].description,"Completado");
                tarea[i].state = State.Completado;
                break;
            }
            unchecked {
                ++i;
            }
        }
    }

}