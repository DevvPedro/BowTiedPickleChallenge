// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";  

error ERC20SPECIAL_CannotBeZero();
error ERC20SPECIAl_InsufficientBalance();
error ERC20SPECIAL_InsufficientAllowance();
error ERC20SPECIAL_MaxSupplyReached();
error ERC20SPECIAL_Maxmint();
error ERC20SPECIAL_NotPaused();
error ERC20SPECIAL_Paused();
error ERC20SPECIAL_NotOwner();
error ERC20SPECIAl_MustBeDifferentCollector();

contract ERC20SPECIAL is IERC20 {

    address public _owner;
    address public taxCollector;

    uint256 private _totalSupply;

    uint256 constant public _CAP = 1000000000;
    uint256 constant public _MAX_MINT = 10000;
    uint256 constant public _TAX = 2;

    mapping (address => uint256 ) private _balance;
    mapping (address => mapping (address => uint) ) private _allowances;

    bool public pause;

      /**
       * @dev : Pauses the mint and burn function. 
       * @notice : _taxCollector cannot be the same as owner.
       */

    constructor() {
       _owner = msg.sender;

    }

      /**
       * @dev : Pauses the mint and burn function. 
       * @notice : Can only be called by address _owner.
       */
    function paused() external  {
        if(msg.sender != _owner) {
            revert ERC20SPECIAL_NotOwner();
        }
        pause = true;
    }
    
      /**
       * @dev : Unpauses the mint and burn function.
       * @notice : Can only be called  by the owner.
       */
    function unPause() external {
       if( msg.sender != _owner) {
            revert ERC20SPECIAL_NotOwner();
         }

        if(!pause) {
            revert ERC20SPECIAL_NotPaused();
        }

        pause = false;
    }

    function transfer(address to, uint256 amount) external override returns (bool) {
        if(to == address(0)) {
            revert ERC20SPECIAL_CannotBeZero();
        }

        address owner = msg.sender;
        uint256 amountAfterTax =_deductTax(amount);
        _transfer(owner, to, amountAfterTax);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
          address owner = msg.sender;
          _approve(owner,spender,amount);
          return true;
    }

    function transferFrom(address owner, address spender, uint256 amount) external override returns (bool) {
        uint256 currentAllowance = allowance(owner,spender);

        if (amount > currentAllowance) {
            revert ERC20SPECIAL_InsufficientAllowance();
        }

        uint256 amountAfterTax = _deductTax(amount);

        _transfer(owner,spender,amountAfterTax);
        unchecked {
        _approve(owner, spender, currentAllowance - amount);
        }

        return true;
    }
   
    function increaseAllowance(address spender, uint256 amount) external {
        address owner = msg.sender;
        _approve(owner,spender, allowance(owner,spender) + amount);
    }

    function decreaseAllowance(address spender, uint256 amount) external {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner,spender);
        if(amount > currentAllowance) {
            revert ERC20SPECIAL_InsufficientAllowance();
        }
        unchecked {
            _approve(owner,spender, currentAllowance - amount);
        }
        }

        function mint(uint256 amount) external {
           if(pause == true) {
           revert ERC20SPECIAL_Paused();
         }
       
        if(totalSupply() ==  _CAP ) {
            revert ERC20SPECIAL_MaxSupplyReached();
        }
        if(amount + totalSupply() > _CAP) {
            revert ERC20SPECIAL_MaxSupplyReached();
        }

        if(amount > _MAX_MINT) {
            revert ERC20SPECIAL_Maxmint();
        }
        address owner = msg.sender;
        // totalSupply Cannot overflow because it is capped at 1000000000
        unchecked {
            _totalSupply += amount;
        }
            _balance[owner] += amount;
           
        emit Transfer(address(0),owner,amount); 

        }

     function burn(uint256 amount) external {
         if(pause == true) {
           revert ERC20SPECIAL_Paused();
         }
        address owner = msg.sender;
        uint256 balance = balanceOf(owner);
        if (amount > balance ) {
        revert ERC20SPECIAl_InsufficientBalance();
        }
            unchecked {
                _balance[owner] -= amount;
                _totalSupply -= amount;
         }
            emit Transfer(owner,address(0), amount);
        }

    function _transfer(address owner, address to, uint256 amount) internal {
        uint256 balance = balanceOf(owner);
        if (amount > balance ) {
        revert ERC20SPECIAl_InsufficientBalance();
        }
        unchecked {
        _balance[owner] -= amount;
        }
        _balance[to] += amount;
        emit Transfer(owner,to,amount);
    }

    function _approve(address owner,address spender, uint256 amount) internal {
        if(spender == address(0)) {
            revert ERC20SPECIAL_CannotBeZero();
        }
        if (owner == address(0)) {
            revert ERC20SPECIAL_CannotBeZero();
        }
        uint256 balance = balanceOf(owner);

        if(amount > balance) {
            revert ERC20SPECIAL_InsufficientAllowance();
        }

         _allowances[owner][spender] = amount;
         emit Approval(owner,spender,amount);
    } 

    function _deductTax(uint256 amount) internal returns (uint256 amountAfterTax)  {
      address owner = msg.sender;
       uint256 tax = (amount * _TAX) / 10000;
        _transfer(owner,_owner,tax);
        // cannot underflow because amount is always greater than tax
        unchecked {
        amountAfterTax = amount - tax;
        }
    }

    function totalSupply() public override view returns (uint256) {
       return _totalSupply;    
    }
    function balanceOf(address account) public override view returns (uint256) {
       return _balance[account];
    }
    
    function allowance(address owner, address spender) public override view returns (uint256) {
      return _allowances[owner][spender];
    }
}


    

 

