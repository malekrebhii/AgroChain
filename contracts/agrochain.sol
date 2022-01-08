pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/AccessControl.sol";

contract StructStorage is AccessControl {

 bytes32 public constant Admin_ROLE = keccak256("Admin");
 bytes32 public constant Farmer_ROLE = keccak256("Farmer");
 bytes32 public constant Tester_ROLE = keccak256("Tester");
 bytes32 public constant Supplier_ROLE = keccak256("Supplier");
 uint256 public s = 0; 
 enum State{ Approved, Pending ,Declined}

constructor()  {
        _setupRole(Admin_ROLE, msg.sender);
    }

struct farmer {

    uint product_id;
    string fname;
    string loc;
    string crop;
    uint256 contact;
    uint quantity;
    uint exprice;
    State status;
    string grade;
    uint mrp;
    uint testdate;
    uint expdate;
}


struct supplier {
    //he can only buy approved product that doesn't exceeds expiration date

    uint product_id;
    string crop;
    uint256 contact;
    uint quantity;
    uint price;
    string grade;
    uint expdate;
}


mapping (address => farmer[]) f1;
mapping (address => supplier[]) s1;
address[] public farmers; // (farmers /suppliers) get updated once role is granted by admin(msg.sender)
address[] public suppliers;

function grantRole(bytes32 role,address account) public override onlyRole(Admin_ROLE) {
        _grantRole(role, account);
        if (role == Farmer_ROLE)
        farmers.push(account);
        else if (role == Supplier_ROLE)
        suppliers.push(account);
    }


function Produce(string memory name, string memory loc, string memory cr, uint con, uint q, uint pr) external onlyRole(Farmer_ROLE){
        StructStorage.farmer memory fnew = farmer(s,name,loc,cr,con,q,pr,State.Pending,"NaN",0,0,0);
        f1[msg.sender].push(fnew);
        s++;
  
}
    
 function getproduce(address f) public view returns(farmer [] memory ) {
        return (f1[f]);
    }

    function getFarmers() public view returns(address [] memory ) {
        return (farmers);
    }
    function getSuppliers() public view returns(address [] memory ) {
        return (suppliers);
    }
 function Approve(uint id ,address _farmer) external onlyRole(Tester_ROLE){
        StructStorage.farmer memory product= f1[_farmer][id];
        product.status=State.Approved;
        f1[_farmer][id]=product;
  
 }  
 
 function Buy(address _farmer , uint id ,uint price ,uint contact,uint qte) external onlyRole(Supplier_ROLE) payable {
        StructStorage.farmer memory product= f1[_farmer][id];
        require(msg.value >= product.exprice*qte );
        require(product.expdate < block.timestamp && product.status == State.Approved && product.quantity >= qte) ;
        StructStorage.supplier memory snew = supplier(product.product_id,product.crop,contact,qte,price,product.grade,product.expdate);
        s1[msg.sender].push(snew);
  
}
}