Class CreateItem.additem
{

ClassMethod AddBusinessItem(pProduction As %String, pName As %String, pClassName As %String, pCategory As %String = "", pEnabled As %Boolean = 1, pLogTraceEvents As %Boolean = 1, pPoolSize As %Integer = 1, pComment As %String = "", pItemType As %Integer) As %Status
{
    Set ret = $$$OK
    write "started",!
    Try {
        // Check the mandatories values
        If ((pName '="") && (pClassName '=""))
        {
            If '##class(Ens.Config.Item).NameExists(pProduction,pName,.idItem)
            {
                Set production = ##class(Ens.Config.Production).%OpenId(pProduction)
                Write !,"Installing "_pName,!
                Set objItem = ##class(Ens.Config.Item).%New()
                Set objItem.Name = pName
                write "pClassName : "_pClassName,!
                Set objItem.ClassName = pClassName
                Set objItem.Enabled = pEnabled
                Set objItem.LogTraceEvents = pLogTraceEvents
                Set objItem.Category = pCategory
                Set objItem.PoolSize = pPoolSize
                Set objItem.Comment = pComment
                ;Set objItem.BusinessType = pItemType


                Do production.Items.Insert(objItem)

                Set st = production.%Save()
                Kill objItem

                Do ##class(Ens.Director).RestartProduction(0,1)
                Write !,"Item "_pName_" installed."
            }
            Else
            {
                Write !,"Item "_pName_" already exists."
            }

        }
        Else
        {
            If (pName = "") set attrib = "pName"
            If (pClassName ="") set attrib = "pClassName"

            $$$ThrowOnError($System.Status.Error(406,attrib))
        }
    }
    Catch ex {
        Set ret = ex.AsStatus()
        Write !,"Error #",$System.Status.GetErrorCodes(ret),!
        Write !,$System.Status.GetOneStatusText(ret,1),!
    }

    Quit ret
}

ClassMethod ImportCSV()
{
    set adapter = ##class(%File).%New("C:\Users\Imtech\Downloads\allitems15.csv")
    set status = adapter.Open("R")

    if $$$ISERR(status)
    {
     do $System.Status.DisplayError(status)
    }

    set counter =1

    while 'adapter.AtEnd
    {
        set line=adapter.ReadLine()
        set rec= ##class(%DynamicObject).%New()
        Set rec.Production = $piece(line,",",1)
        Set rec.Name = $piece(line,",",2)
        Set rec.ClassName = $piece(line,",",3)
        Set rec.Enabled = $piece(line,",",4)
        Set rec.LogTraceEvents = $piece(line,",",5)
        Set rec.Category = $piece(line,",",6)
        Set rec.PoolSize = $piece(line,",",7)
        Set rec.Comment = $piece(line,",",8)
        Set rec.ItemType = $piece(line,",",9)

        ;Set savestatus=rec.%Save()
        /*
        if $$$ISERR(savestatus)
        {
         do $System.Status.DisplayError(status)
        }
        */
        if rec.Production '=""
        {
            set tsc= ..AddBusinessItem(rec.Production, rec.Name, rec.ClassName, rec.Enabled, rec.LogTraceEvents, rec.Category, rec.PoolSize, rec.Comment, rec.ItemType)
        }
        else {quit}
    }
    
      //if error found during processing,show it
      if $$$ISERR(status)
      {
       do $System.Status.DisplayError(status)
      }
}

}
