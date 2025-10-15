# Enunciado del Contrato Inteligente "DonationsV2"


### Objetivo: 

Crear un contrato inteligente para gestionar donaciones en Ethereum, 
permitiendo a los usuarios donar tanto en ETH como en USDC. El contrato también 
recompensará a los donantes con un NFT después de alcanzar un umbral de donaciones.

### Características:

Propiedad: El contrato es propiedad de un único administrador que tiene el control 
sobre ciertas funciones críticas como el retiro de fondos y la actualización del oracle.

### Donaciones:

Permite donaciones en ETH mediante la función doeETH(), que convierte la cantidad donada 
a su valor en USD utilizando un oracle de Chainlink.
Permite donaciones en USDC mediante la función doeUSDC(uint256 _usdcAmount).

### Recompensas:

Los usuarios que donen más de un umbral establecido (1000 USDC) recibirán un NFT como 
recompensa si no poseen uno previamente.
Retiro de Fondos:

La función saque() permite al propietario retirar los fondos donados, ya sean en ETH o USDC.

### Actualización del Oracle:

Permite al propietario actualizar la dirección del oracle de precios de Chainlink mediante la 
función setFeeds(address _feed).


### Eventos:

Emite eventos para registrar cada donación, retiro de fondos y actualizaciones del oracle.


### Seguridad:

Implementa manejo de errores y validaciones para asegurar la correcta ejecución de las donaciones y 
retiros, incluyendo la verificación de que el oracle no esté comprometido y que el precio no esté obsoleto.



Nota: al codigo implementado acá le falta seguridad y optimización, solo está el aspecto funcional.